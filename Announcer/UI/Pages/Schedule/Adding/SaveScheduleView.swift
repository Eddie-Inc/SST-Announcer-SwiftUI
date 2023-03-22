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

    var body: some View {
        List {
            LargeListHeader(image: .init(systemName: "square.and.arrow.down"),
                            title: "Save Schedule")

            Section("Timetable") {
                ScheduleVisualiserView(scheduleSuggestion: scheduleSuggestion)
            }

            Section {
                ListTextField("Name:", value: .init(get: {
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
                    save()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationSheet {
                    List {
                        ScheduleLoadingFAQView()
                    }
                } label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.accentColor)
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
