//
//  ScheduleInformationView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 25/2/23.
//

import SwiftUI
import Chopper

struct ScheduleInformationView: View {
    @ObservedObject var manager: ScheduleManager = .default
    @State var editedSchedule: Schedule

    @Environment(\.presentationMode) var presentationMode
    @Binding var showProvideSchedule: Bool

    init(showProvideSchedule: Binding<Bool>) {
        let manager = ScheduleManager.default
        guard let schedule = manager.currentSchedule else { fatalError("Schedule not found") }
        self._manager = .init(wrappedValue: manager)
        self._editedSchedule = .init(wrappedValue: schedule)
        self._showProvideSchedule = showProvideSchedule
    }

    var body: some View {
        List {
            Section {
                ScheduleVisualiserView(scheduleSuggestion: editedSchedule)
            }

            Section("Information") {
                DatePicker("Start Date",
                           selection: $editedSchedule.startDate,
                           displayedComponents: .date)
                .onChange(of: editedSchedule.startDate) { _ in
                    editedSchedule.fixStartDate()
                }
                DatePicker("End Date",
                           selection: .init(get: { editedSchedule.endDate }, set: { _ in }),
                           displayedComponents: .date)
                .disabled(true)
                Picker("Number of weeks", selection: $editedSchedule.repetitions) {
                    ForEach(Array(1...10), id: \.self) { index in
                        Text("\(index*2)")
                            .tag(index)
                    }
                }
            }

            Section("Subjects and Classes") {
                NavigationSheet("Odd Week") {
                    NavigationView {
                        List {
                            WeekSubjectsView(schedule: $editedSchedule, week: .odd)
                        }
                    }
                }
                NavigationSheet("Even Week") {
                    NavigationView {
                        List {
                            WeekSubjectsView(schedule: $editedSchedule, week: .even)
                        }
                    }
                }
            }

            Section {
                Button("Save") {
                    manager.overwriteSchedule(schedule: editedSchedule)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(manager.currentSchedule == editedSchedule)
                Button("Remove") {
                    // TODO: Add confirmation
                    // TODO: Fix the unwrapping bug
                    manager.removeSchedule(id: manager.currentSchedule.id)
                }
                Button("Upload new schedule") {
                    presentationMode.wrappedValue.dismiss()
                    showProvideSchedule = true
                }
            }
        }
    }
}
