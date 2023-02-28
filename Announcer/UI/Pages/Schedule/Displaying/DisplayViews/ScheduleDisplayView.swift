//
//  ScheduleDisplayView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 23/2/23.
//

import SwiftUI
import Chopper
import PostManager

struct ScheduleDisplayView: View {
    @State var schedule: Schedule
    @State var showInfo: Bool = false
    var today: Date = .now

    init() {
        let value = read(Schedule.self, from: "schedule")!
        self._schedule = State(wrappedValue: value)
    }

    var body: some View {
        List {
            if schedule.nowInRange {
                todayView
            } else {
                Section {
                    if schedule.startDate > .now {
                        Text("Schedule starts on \(schedule.startDate.formatted(date: .abbreviated, time: .omitted))")
                    } else {
                        Text("Schedule ended on \(schedule.endDate.formatted(date: .abbreviated, time: .omitted))")
                    }
                    Button("Edit Schedule") {
                        showInfo = true
                    }
                }
            }

            Section {
                NavigationLink("Classes") {
                    ClassesDisplayView(schedule: schedule)
                }
            }
        }
        .navigationTitle("Schedule")
        .sheet(isPresented: $showInfo) {
            if #available(iOS 16.0, *) {
                ScheduleInformationView(schedule: $schedule)
                    .presentationDetents([.medium, .large])
            } else {
                ScheduleInformationView(schedule: $schedule)
            }
        }
    }

    var todayView: some View {
        Section {
            if let day = today.weekday.dayOfWeek {
                ForEach(schedule.subjectsMatching(day: day, week: schedule.currentWeek)) { subject in
                    if #available(iOS 16.0, *) {
                        ZStack {
                            SubjectDisplayView(today: today,
                                               subject: subject,
                                               allowShowingAsCurrent: today.weekday.dayOfWeek != nil)
                                .contextMenu {
                                    Button("Copy Details") {}
                                } preview: {
                                    OtherSubjectInstancesView(schedule: schedule, subClass: subject.subjectClass)
                                }
                            NavigationLink {
                                OtherSubjectInstancesView(schedule: schedule,
                                                          subClass: subject.subjectClass,
                                                          showVisualiser: true)
                            } label: {}.opacity(0)
                        }
                        .listRowSeparator(.hidden)
                    } else {
                        ZStack {
                            SubjectDisplayView(today: today,
                                               subject: subject,
                                               allowShowingAsCurrent: today.weekday.dayOfWeek != nil)
                                .contextMenu {
                                    Button("Copy Details") {}
                                }
                            NavigationLink {
                                OtherSubjectInstancesView(schedule: schedule,
                                                          subClass: subject.subjectClass,
                                                          showVisualiser: true)
                            } label: {}.opacity(0)
                        }
                        .listRowSeparator(.hidden)
                    }
                }

                ScheduleVisualiserView(scheduleSuggestion: schedule,
                                       week: .init(weekNo: schedule.currentWeek))
                .frame(height: 80)
            } else {
                ScheduleVisualiserView(scheduleSuggestion: schedule,
                                       week: .init(weekNo: schedule.currentWeek+1))
                .frame(height: 80)
            }
        } header: {
            HStack {
                if today.weekday.dayOfWeek == nil {
                    Text("Next week: W\(schedule.currentWeek+1)")
                } else {
                    Text("W\(schedule.currentWeek), \(today.weekday.rawValue.firstLetterUppercase)")
                }
                Spacer()
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
    }
}
