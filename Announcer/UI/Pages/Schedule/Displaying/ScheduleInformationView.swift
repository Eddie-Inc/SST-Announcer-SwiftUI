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

    @Binding var showInfo: Bool
    @Binding var showProvideSchedule: Bool

    init(showInfo: Binding<Bool>, showProvideSchedule: Binding<Bool>) {
        let manager = ScheduleManager.default
        guard let schedule = manager.currentSchedule else { fatalError("Schedule not found") }
        self._manager = .init(wrappedValue: manager)
        self._editedSchedule = .init(wrappedValue: schedule)
        self._showInfo = showInfo
        self._showProvideSchedule = showProvideSchedule
    }

    var body: some View {
        List {
            Section {
                ScheduleVisualiserView(scheduleSuggestion: editedSchedule)
            }

            Section("Information") {
                ListTextField("Name", value: .init(get: {
                    editedSchedule.name ?? "Untitled"
                }, set: { newValue in
                    editedSchedule.name = newValue
                }))
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
                NavigationLink("Subjects") {
                    List {
                        Section("Odd Week") {
                            WeekSubjectsView(schedule: $editedSchedule, week: .odd)
                        }
                        Section("Even Week") {
                            WeekSubjectsView(schedule: $editedSchedule, week: .even)
                        }
                    }
                    .navigationTitle("Subjects")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }

            Section {
                NavigationLink("Manage Schedules") {
                    SwitchScheduleView(showInfo: $showInfo, showProvideSchedule: $showProvideSchedule)
                }
            }

            Section {
                Button("Save") {
                    editedSchedule.id = manager.currentSchedule.id
                    manager.overwriteSchedule(schedule: editedSchedule)
                    showInfo = false
                }
                .disabled(manager.currentSchedule == editedSchedule)
            }
        }
    }
}
