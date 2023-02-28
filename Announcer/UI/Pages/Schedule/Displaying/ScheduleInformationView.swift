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

    init() {
        let manager = ScheduleManager.default
        guard let schedule = manager.currentSchedule else { fatalError("Schedule not found") }
        self._manager = .init(wrappedValue: manager)
        self._editedSchedule = .init(wrappedValue: schedule)
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
                NavigationSheet("Week One") {
                    NavigationView {
                        List {
                            WeekSubjectsView(schedule: $editedSchedule, week: .one)
                        }
                    }
                }
                NavigationSheet("Week Two") {
                    NavigationView {
                        List {
                            WeekSubjectsView(schedule: $editedSchedule, week: .two)
                        }
                    }
                }
            }

            Section {
                Button("Save") {
                    manager.writeSchedule(schedule: editedSchedule)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(manager.currentSchedule == editedSchedule)
            }
        }
    }
}
