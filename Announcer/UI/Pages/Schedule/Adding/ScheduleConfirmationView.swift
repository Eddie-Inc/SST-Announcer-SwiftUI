//
//  ScheduleConfirmationView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 21/3/23.
//

import SwiftUI
import Chopper
import Updating

struct ScheduleConfirmationView: View {

    @Updating var scheduleConfirmation: ScheduleConfirmation
    @Binding var showProvideSuggestion: Bool

    @ObservedObject
    var manager: ScheduleManager = .default

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            switch scheduleConfirmation {
            case .askForConfirmation(let schedule):
                viewFor(schedule: schedule)
            case .idMatchesAskForConfirmation(let schedule, let schedule2):
                viewFor(schedule: schedule, matchingSchedule: schedule2)
            }
        }
    }

    @ViewBuilder
    func viewFor(schedule: Schedule, matchingSchedule: Schedule? = nil) -> some View {
        Section("New Schedule: \(schedule.name ?? "Untitled")") {
            ScheduleVisualiserView(scheduleSuggestion: schedule)
        }

        Section {
            if let matchingSchedule {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text("May be a duplicate of schedule \"\(matchingSchedule.name ?? "Untitled")\"")
                }
            }
            Button("Add Schedule") {
                var mutableSchedule = schedule
                mutableSchedule.id = .init()
                saveSchedule(schedule: mutableSchedule)
            }
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    func saveSchedule(schedule: Schedule) {
        let manager = ScheduleManager.default
        manager.addSchedule(schedule: schedule)
        presentationMode.wrappedValue.dismiss()
        showProvideSuggestion = false
    }
}

enum ScheduleConfirmation: Identifiable {
    /// Asks the user for confirmation for a certain schedule
    case askForConfirmation(Schedule)
    /// Asks the user for confirmatino for a certain schedule, given that it matches another schedule
    case idMatchesAskForConfirmation(Schedule, Schedule)

    var id: UUID {
        switch self {
        case .askForConfirmation(let schedule):
            return schedule.id
        case .idMatchesAskForConfirmation(let schedule, _):
            return schedule.id
        }
    }
}
