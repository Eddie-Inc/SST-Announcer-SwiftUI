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
        fetchSchedule()
    }

    /// The current schedule, if it exists. Requires ``fetchSchedule()`` for initial population.
    @Published public var currentSchedule: Schedule?
    /// An unwrapped version of ``currentSchedule``
    public var schedule: Schedule {
        get {
            currentSchedule!
        }
        set {
            currentSchedule = newValue
        }
    }

    /// If there is a schedule in storage.
    /// Refreshed upon call to ``fetchSchedule()``, ``saveSchedule()`` or ``writeSchedule(schedule:)``.
    public var hasScheduleInStorage: Bool = false

    /// Populates the ``currentSchedule``. Returns a value representing if it was successful or not.
    @discardableResult
    public func fetchSchedule() -> Bool { // swiftlint:disable:this attributes
        defer { objectWillChange.send() }

        if let schedule = read(Schedule.self, from: "schedule") {
            self.currentSchedule = schedule
            hasScheduleInStorage = true
            return true
        }
        hasScheduleInStorage = false
        return false
    }

    /// Writes the ``currentSchedule`` to memory
    public func saveSchedule() {
        guard let currentSchedule else { return }
        write(currentSchedule, to: "schedule")
        hasScheduleInStorage = exists(file: "schedule")
        objectWillChange.send()
    }

    /// Writes a provided schedule to memory, replacing ``currentSchedule``.
    public func writeSchedule(schedule: Schedule) {
        write(schedule, to: "schedule")
        self.currentSchedule = schedule
        hasScheduleInStorage = exists(file: "schedule")
        objectWillChange.send()
    }
}
