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

    @State var compactTop: Bool = true
    var todayView: some View {
        Section {
            if let day = today.weekday.dayOfWeek {
                // leading things
                if indexOfCurrentSubject(day: day) > 3 && compactTop {
                    HStack {
                        ForEach(0..<min(3, indexOfCurrentSubject(day: day) - 3), id: \.self) { index in
                            schedule.subjectsMatching(day: day, week: schedule.currentWeek)[index].displayColor
                                .frame(width: 10, height: 25)
                                .cornerRadius(5)
                        }
                        Text("\(indexOfCurrentSubject(day: day) - 3) subjects")
                            .padding(.horizontal, 5)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal, -10)
                    .onTapGesture {
                        withAnimation {
                            compactTop = false
                        }
                    }
                }
                ForEach(Array(schedule.subjectsMatching(day: day, week: schedule.currentWeek).enumerated()),
                        id: \.0) { (index, subject) in
                    if indexOfCurrentSubject(day: day) - index <= 3 || !compactTop {
                        viewForSubject(subject: subject)
                    }
                }

//                ScheduleVisualiserView(scheduleSuggestion: schedule,
//                                       week: .init(weekNo: schedule.currentWeek))
//                .frame(height: 80)
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
                if !compactTop {
                    Button {
                        withAnimation {
                            compactTop = true
                        }
                    } label: {
                        Image(systemName: "circle")
                    }
                }
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
    }

    @ViewBuilder
    func viewForSubject(subject: Subject) -> some View {
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

    func indexOfCurrentSubject(day: DayOfWeek) -> Int {
        let subjects = schedule.subjectsMatching(day: day, week: schedule.currentWeek)
        let todayTime = Date().formattedTime

        // during available subjects
        if let index = subjects.firstIndex(where: { $0.contains(time: todayTime) }) {
            return index
        }

        // before start
        if let start = subjects.first?.estimatedTimeRange().0, start > todayTime {
            return -1
        }

        // after end
        if let end = subjects.last?.estimatedTimeRange().1, end < todayTime {
            return subjects.count
        }

        // default to before start
        return -1
    }
}
