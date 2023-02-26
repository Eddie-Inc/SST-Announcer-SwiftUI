//
//  ScheduleSuggestionView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 16/2/23.
//

import SwiftUI
import Chopper

struct ScheduleSuggestionView: View {
    @State var scheduleSuggestion: ScheduleSuggestion
    @State var selectedWeek: Week?
    @State var showClasses: Bool = false

    @Binding var showProvideSuggestion: Bool

    var body: some View {
        List {
            LargeListHeader(image: Image(systemName: "calendar.day.timeline.left"),
                            title: "Configure Schedule",
                            detailText: "Ensure the detected data is correct")

            Section("Timetable") {
                ScheduleVisualiserView(scheduleSuggestion: scheduleSuggestion)
            }

            Section("Subjects and Classes") {
                NavigationSheet("Classes") {
                    List {
                        ForEach(scheduleSuggestion.subjectClasses) { subClass in
                            ClassDisplayView(subClass: subClass)
                        }
                        .onDelete { indexSet in
                            let classes = scheduleSuggestion.subjectClasses
                            for index in indexSet {
                                scheduleSuggestion.deleteClass(subClass: classes[index])
                            }
                        }
                        .onMove { indexSet, index in
                            scheduleSuggestion.subjects.move(fromOffsets: indexSet, toOffset: index)
                        }
                    }
                }
                ForEach(Week.allCases) { week in
                    Button {
                        selectedWeek = week
                    } label: {
                        HStack {
                            Text("Week \(week.rawValue.firstLetterUppercase)")
                            Spacer()
                            Text("\(scheduleSuggestion.subjects.filter({ $0.day.week == week }).invalidSuggestions)")
                            Image(systemName: "exclamationmark.triangle")
                        }
                        .foregroundColor(.primary)
                    }
                }
            }

            Section {
                NavigationLink {
                    // save screen
                    SaveScheduleView(scheduleSuggestion: scheduleSuggestion,
                                     showProvideSuggestion: $showProvideSuggestion)
                } label: {
                    // debug message
                    HStack {
                        if scheduleSuggestion.loadProgress == .loaded {
                            if scheduleSuggestion.invalidSuggestions > 0 {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.red)
                                Text("There are \(scheduleSuggestion.invalidSuggestions) unassigned subjects")
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text("Continue")
                            }
                        } else {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                            Text("Loading subjects...")
                        }
                        Spacer()
                    }
                }
                .disabled(!(scheduleSuggestion.invalidSuggestions == 0 &&
                            scheduleSuggestion.loadProgress == .loaded))
            }
        }
        .sheet(item: $selectedWeek) { week in
            if #available(iOS 16.0, *) {
                NavigationView {
                    List {
                        WeekSubjectsView(schedule: $scheduleSuggestion, week: week)
                    }
                    .navigationTitle("Week \(week.rawValue.firstLetterUppercase)")
                }
                .presentationDetents([.medium, .large])
            } else {
                NavigationView {
                    List {
                        WeekSubjectsView(schedule: $scheduleSuggestion, week: week)
                    }
                    .navigationTitle("Week \(week.rawValue.firstLetterUppercase)")
                }
            }
        }
    }
}

struct ScheduleSuggestionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleSuggestionView(scheduleSuggestion: .init(sourceImage: UIImage(named: "timetable")!)!,
                                   showProvideSuggestion: .constant(true))
        }
    }
}
