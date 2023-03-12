//
//  ScheduleManager.swift
//  
//
//  Created by Kai Quan Tay on 28/2/23.
//

import SwiftUI

public class ScheduleManager: ObservableObject {
    public static let `default`: ScheduleManager = .init()

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
        else { return false }

        var schedules: [Schedule] = []

        for content in contents {
            if let schedule = read(Schedule.self, from: "schedules/\(content)") {
                schedules.append(schedule)
            }
        }

        self.schedules = schedules
        if let first = schedules.first {
            switchSchedule(to: first.id)
        }

        return true
    }

    // MARK: Current schedule operations

    /// The current schedule, if it exists. Requires ``fetchSchedule()`` for initial population.
    /// It is a `Schedule!` for ease of use. Use a `guard let` statement whenever this may be nil.
    @Published public var currentSchedule: Schedule!

    /// Writes the ``currentSchedule`` to memory
    public func saveSchedule() {
        guard let currentSchedule else { return }
        write(currentSchedule, to: "schedule")
        objectWillChange.send()
    }

    /// Writes a provided schedule to memory, replacing ``currentSchedule``.
    public func overwriteSchedule(schedule: Schedule) {
        if !exists(file: "schedules") {
            makeDirectory(name: "schedules")
        }

        write(schedule, to: "schedules/schedule")
        self.currentSchedule = schedule
        objectWillChange.send()
    }

    /// Deletes the schedule file
    public func removeCurrentSchedule() {
        let documents = getDocumentsDirectory()
        let filePath = documents.appendingPathComponent("schedule")
        try? FileManager.default.removeItem(at: filePath)
        self.currentSchedule = nil
        objectWillChange.send()
    }

    // MARK: Managing schedules
    @discardableResult
    public func switchSchedule(to newID: Schedule.ID) -> Bool {
        if let newSchedule = schedules.first(where: { $0.id == newID }) {
            currentSchedule = newSchedule
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
    }

    /// A list of available schedules
    @Published public var schedules: [Schedule]
}
