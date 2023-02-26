//
//  ScheduleInformationView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 25/2/23.
//

import SwiftUI
import Chopper
import PostManager

struct ScheduleInformationView: View {
    @Binding var schedule: Schedule
    @State var editedSchedule: Schedule

    @Environment(\.presentationMode) var presentationMode

    init(schedule: Binding<Schedule>) {
        self._schedule = schedule
        self._editedSchedule = .init(wrappedValue: schedule.wrappedValue)
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
                    editedSchedule.setStartDateToMonday()
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
                    schedule = editedSchedule
                    write(schedule, to: "schedule")
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(schedule == editedSchedule)
            }
        }
    }
}
