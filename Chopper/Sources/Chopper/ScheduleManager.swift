//
//  ScheduleManager.swift
//  
//
//  Created by Kai Quan Tay on 28/2/23.
//

import SwiftUI

let defaults = UserDefaults.standard
public class ScheduleManager: ObservableObject {
    public static let `default`: ScheduleManager = .init()

    var currentScheduleID: UUID? {
        didSet {
            defaults.set(currentScheduleID?.uuidString, forKey: "currentScheduleID")
        }
    }

    private init() {
        self.schedules = []
        fetchSchedules()
    }

    /// Populates the ``currentSchedule``. Returns a value representing if it was successful or not.
    @discardableResult
    public func fetchSchedules() -> Bool { // swiftlint:disable:this attributes
        defer { objectWillChange.send() }

        // ensure that the schedules folder actually exists
        let folderPath = getDocumentsDirectory().appendingPathComponent("schedules")
        print("Fetching path: \(folderPath)")

        guard exists(file: "schedules"),
              let contents = try? FileManager.default.contentsOfDirectory(atPath: folderPath.path)
        else {
            makeDirectory(name: "schedules")
            return false
        }

        // read schedules
        var schedules: [Schedule] = []
        for content in contents {
            if var schedule = read(Schedule.self, from: "schedules/\(content)") {
                schedule.id = .init(uuidString: content)!
                schedules.append(schedule)
            }
        }

        // switch schedules
        self.schedules = schedules
        if let scheduleUUIDString = defaults.string(forKey: "currentScheduleID"),
           let scheduleUUID = UUID(uuidString: scheduleUUIDString) {
            currentScheduleID = scheduleUUID
            switchSchedule(to: scheduleUUID)
        }

        return true
    }

    // MARK: Current schedule operations

    /// The current schedule, if it exists. Requires ``fetchSchedule()`` for initial population.
    /// It is a `Schedule!` for ease of use. Use a `guard let` statement whenever this may be nil.
    @Published public var currentSchedule: Schedule!

    /// Writes the schedule with the given ID, or ``currentSchedule`` by default, to memory
    public func saveSchedule(id: Schedule.ID? = nil) {
        if let id, let scheduleToSave = schedules.first(where: { $0.id == id }) {
            print("Saving schedule: \(scheduleToSave.id)")
            write(scheduleToSave, to: "schedules/\(scheduleToSave.id.description)")
        } else {
            guard let currentSchedule else { return }
            write(currentSchedule, to: "schedules/\(currentSchedule.id.description)")
        }
        objectWillChange.send()
    }

    /// Writes a provided schedule to memory, replacing ``currentSchedule``.
    /// It does not delete the file for ``currentSchedule``, so if their IDs are different, the old ``currentSchedule`` will remain.
    public func overwriteSchedule(schedule: Schedule) {
        write(schedule, to: "schedules/\(schedule.id.description)")
        self.currentSchedule = schedule

        guard let scheduleIndex = schedules.firstIndex(where: { $0.id == schedule.id }) else { return }
        schedules[scheduleIndex] = schedule

        objectWillChange.send()
    }

    /// Deletes the schedule file
    public func removeCurrentSchedule() {
        guard let currentSchedule else { return }
        let documents = getDocumentsDirectory()
        let filePath = documents.appendingPathComponent("schedules/\(currentSchedule.id)")
        try? FileManager.default.removeItem(at: filePath)

        guard let scheduleIndex = schedules.firstIndex(where: { $0.id == currentSchedule.id }) else { return }
        schedules.remove(at: scheduleIndex)
        self.currentSchedule = nil

        objectWillChange.send()
    }

    // MARK: Managing schedules
    @discardableResult
    public func switchSchedule(to newID: Schedule.ID) -> Bool {
        if let newSchedule = schedules.first(where: { $0.id == newID }) {
            currentSchedule = newSchedule
            currentScheduleID = newSchedule.id
            objectWillChange.send()
            return true
        }
        return false
    }

    public func removeSchedule(id: Schedule.ID) {
        schedules.removeAll(where: { $0.id == id })
        if let currentSchedule, currentSchedule.id == id {
            self.currentSchedule = nil
        }
        let path = getDocumentsDirectory().appendingPathComponent("schedules/\(id.description)")
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            print("Could not remove schedule at path \(path.absoluteString)")
        }
    }

    public func addSchedule(schedule: Schedule) {
        self.schedules.append(schedule)
        write(schedule, to: "schedules/\(schedule.id.description)")
        // set the current schedule
        self.currentSchedule = schedule
        objectWillChange.send()
    }

    /// A list of available schedules
    @Published public var schedules: [Schedule]
}
