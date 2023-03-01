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

    init() {
        let manager = ScheduleManager.default
        let today = Date.now
        self._day = State(wrappedValue: .init(week: manager.schedule.currentWeek%2 == 0 ? .even : .odd,
                                              day: today.weekday.dayOfWeek ?? .monday))
    }

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

    @State var day: Day
    var todayValue: Day {
        let todayDay = today.weekday.dayOfWeek ?? .monday
        return Day(week: manager.schedule.currentWeek%2 == 0 ? .even : .odd,
                   day: todayDay)
    }

    var isCurrentDay: Bool {
        // if the day of week is nil, its always false.
        guard today.weekday.dayOfWeek != nil else { return false }
        return day.description == todayValue.description
    }

    var todayView: some View {
        Section {
            DayPickerView(selection: $day, schedule: manager.schedule, today: todayValue)
                .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
            // leading things
            if indexOfCurrentSubject(day: day) > 3 && compactTop {
                HStack {
                    HStack {
                        ForEach(0..<min(3, indexOfCurrentSubject(day: day) - 3), id: \.self) { index in
                            manager.schedule.subjectsMatching(day: day.day, week: day.week)[index]
                                .displayColor
                                .frame(width: 10, height: 25)
                                .cornerRadius(5)
                        }
                    }
                    .overlay(alignment: .leading) {
                        LinearGradient(stops: [
                            .init(color: .clear, location: 0.2),
                            .init(color: .background, location: 1)
                        ],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                        .frame(width: 50)
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
            ForEach(Array(manager.schedule.subjectsMatching(day: day.day,
                                                            week: day.week).enumerated()),
                    id: \.0) { (index, subject) in
                if indexOfCurrentSubject(day: day) - index <= 3 || !compactTop {
                    viewForSubject(subject: subject)
                }
            }
        } header: {
            HStack {
                if today.weekday.dayOfWeek == nil {
                    Text("Next week: W\(manager.schedule.currentWeek+1)")
                } else {
                    Text("W\(manager.schedule.currentWeek), \(today.weekday.rawValue.firstLetterUppercase)")
                }
                Spacer()
                if indexOfCurrentSubject(day: day) > 3 {
                    Button {
                        withAnimation {
                            compactTop.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                            .rotationEffect(.degrees(compactTop ? 0 : 180))
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
            SubjectDisplayView(today: today,
                               subject: subject,
                               allowShowingAsCurrent: isCurrentDay)
            .contextMenu {
                Button("Copy Details") {}
            } preview: {
                OtherSubjectInstancesView(schedule: manager.schedule, subClass: subject.subjectClass)
            }
            .overlay {
                NavigationLink {
                    OtherSubjectInstancesView(schedule: manager.schedule,
                                              subClass: subject.subjectClass,
                                              showVisualiser: true)
                } label: {}.opacity(0)
            }
            .listRowSeparator(.hidden)
        } else {
            SubjectDisplayView(today: today,
                               subject: subject,
                               allowShowingAsCurrent: isCurrentDay)
            .contextMenu {
                Button("Copy Details") {}
            }
            .overlay {
                NavigationLink {
                    OtherSubjectInstancesView(schedule: manager.schedule,
                                              subClass: subject.subjectClass,
                                              showVisualiser: true)
                } label: {}.opacity(0)
            }
            .listRowSeparator(.hidden)
        }
    }

    func indexOfCurrentSubject(day: Day) -> Int {
        guard isCurrentDay else { return -1 }

        let subjects = manager.schedule.subjectsMatching(day: day.day, week: day.week)
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
