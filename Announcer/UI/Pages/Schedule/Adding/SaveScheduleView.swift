//
//  SaveScheduleView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 23/2/23.
//

import SwiftUI
import PostManager
import Chopper

struct SaveScheduleView: View {
    @State var scheduleSuggestion: ScheduleSuggestion
    @Binding var showProvideSuggestion: Bool

    @State var showConfirmAlert: Bool = false

    var body: some View {
        List {
            LargeListHeader(image: .init(systemName: "square.and.arrow.down"),
                            title: "Save Schedule")

            Section("Timetable") {
                ScheduleVisualiserView(scheduleSuggestion: scheduleSuggestion)
            }

            Section {
                DatePicker("Start Date",
                           selection: $scheduleSuggestion.startDate,
                           displayedComponents: .date)
                .onChange(of: scheduleSuggestion.startDate) { _ in
                    scheduleSuggestion.fixStartDate()
                }
                Picker("Number of weeks", selection: $scheduleSuggestion.repetitions) {
                    ForEach(Array(1...10), id: \.self) { index in
                        Text("\(index*2)")
                            .tag(index)
                    }
                }
            }

            Section {
                Button("Save") {
                    if read(Schedule.self, from: "schedule") == nil {
                        save()
                    } else {
                        showConfirmAlert = true
                    }
                }
                .alert("This will replace your current schedule. Do you want to proceed?",
                       isPresented: $showConfirmAlert) {
                    Button("Proceed") {
                        save()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
    }

    func save() {
        let schedule = Schedule(from: scheduleSuggestion)
        write(schedule, to: "schedule")
        showProvideSuggestion = false
    }
}
