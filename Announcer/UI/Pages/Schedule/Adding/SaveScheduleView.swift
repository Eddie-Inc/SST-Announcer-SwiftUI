//
//  SaveScheduleView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 23/2/23.
//

import SwiftUI
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
                TextField("Name", text: .init(get: {
                    scheduleSuggestion.name ?? "Untitled"
                }, set: { newValue in
                    scheduleSuggestion.name = newValue
                }))
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
                    let manager = ScheduleManager.default
                    if let _ = manager.currentSchedule {
                        showConfirmAlert = true
                    } else {
                        save()
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
        let manager = ScheduleManager.default
        manager.addSchedule(schedule: schedule)
        showProvideSuggestion = false
    }
}
