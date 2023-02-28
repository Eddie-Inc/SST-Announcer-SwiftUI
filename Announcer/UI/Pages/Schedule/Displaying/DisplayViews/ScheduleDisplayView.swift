//
//  ScheduleDisplayView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 23/2/23.
//

import SwiftUI
import Chopper

struct ScheduleDisplayView: View {
    @ObservedObject var manager: ScheduleManager = .default
    @State var showInfo: Bool = false

    @State var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State var today: Date = .now

    var body: some View {
        List {
            if manager.schedule.nowInRange {
                todayView
            } else {
                Section {
                    if manager.schedule.startDate > .now {
                        Text(
"Schedule starts on \(manager.schedule.startDate.formatted(date: .abbreviated, time: .omitted))"
)
                    } else {
                        Text(
"Schedule ended on \(manager.schedule.endDate.formatted(date: .abbreviated, time: .omitted))"
)
                    }
                    Button("Edit Schedule") {
                        showInfo = true
                    }
                }
            }

            Section {
                NavigationLink("Classes") {
                    ClassesDisplayView(schedule: manager.schedule)
                }
            }
        }
        .onReceive(timer) { _ in
            self.today = .now
        }
        .navigationTitle("Schedule")
        .sheet(isPresented: $showInfo) {
            if #available(iOS 16.0, *) {
                ScheduleInformationView()
                    .presentationDetents([.medium, .large])
            } else {
                ScheduleInformationView()
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
                            manager.schedule.subjectsMatching(day: day,
                                                              week: manager.schedule.currentWeek)[index]
                                .displayColor
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
                ForEach(Array(manager.schedule.subjectsMatching(day: day,
                                                                week: manager.schedule.currentWeek).enumerated()),
                        id: \.0) { (index, subject) in
                    if indexOfCurrentSubject(day: day) - index <= 3 || !compactTop {
                        viewForSubject(subject: subject)
                    }
                }

//                ScheduleVisualiserView(scheduleSuggestion: schedule,
//                                       week: .init(weekNo: schedule.currentWeek))
//                .frame(height: 80)
            } else {
                ScheduleVisualiserView(scheduleSuggestion: manager.schedule,
                                       week: .init(weekNo: manager.schedule.currentWeek+1))
                .frame(height: 80)
            }
        } header: {
            HStack {
                if today.weekday.dayOfWeek == nil {
                    Text("Next week: W\(manager.schedule.currentWeek+1)")
                } else {
                    Text("W\(manager.schedule.currentWeek), \(today.weekday.rawValue.firstLetterUppercase)")
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
                    OtherSubjectInstancesView(schedule: manager.schedule, subClass: subject.subjectClass)
                }
                NavigationLink {
                    OtherSubjectInstancesView(schedule: manager.schedule,
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
                    OtherSubjectInstancesView(schedule: manager.schedule,
                                              subClass: subject.subjectClass,
                                              showVisualiser: true)
                } label: {}.opacity(0)
            }
            .listRowSeparator(.hidden)
        }
    }

    func indexOfCurrentSubject(day: DayOfWeek) -> Int {
        let subjects = manager.schedule.subjectsMatching(day: day, week: manager.schedule.currentWeek)
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
