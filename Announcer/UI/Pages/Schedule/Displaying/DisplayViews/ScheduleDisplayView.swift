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
    @ObservedObject var settings: SettingsManager = .shared
    @State var showInfo: Bool = false
    @State var showProvideSchedule: Bool = false
    @State var showQRView: Bool = false

    @State var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State var today: Date = .now

    @State var offsetAmount: Int = 0

    init() {
        let manager = ScheduleManager.default
        let today = Date.now
        self._day = State(wrappedValue: .init(week: manager.currentSchedule.currentWeek%2 == 0 ? .even : .odd,
                                              day: today.weekday.dayOfWeek ?? .monday))
    }

    var body: some View {
        List {
            if manager.currentSchedule.nowInRange {
                todayView
            } else {
                Section {
                    if manager.currentSchedule.startDate > .now {
                        Text(
"Schedule starts on \(manager.currentSchedule.startDate.formatted(date: .abbreviated, time: .omitted))"
)
                    } else {
                        Text(
"Schedule ended on \(manager.currentSchedule.endDate.formatted(date: .abbreviated, time: .omitted))"
)
                    }
                    Button("Edit Schedule") {
                        showInfo = true
                    }
                }
            }

            Section {
                NavigationLink("Classes") {
                    ClassesDisplayView(schedule: manager.currentSchedule)
                }
            }
        }
        .onReceive(timer) { _ in
            self.today = .now.addingTimeInterval(Double(offsetAmount * 60 * 20))
        }
        .navigationTitle(manager.currentSchedule?.name ?? "Schedule")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showQRView = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .sheet(isPresented: $showInfo) {
            NavigationView {
                ScheduleInformationView(showProvideSchedule: $showProvideSchedule)
                    .navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $showQRView) {
            if #available(iOS 16.0, *) {
                ScheduleQRView()
                    .presentationDetents([.medium])
            } else {
                ScheduleQRView()
            }
        }
    }

    @State var compactTop: Bool = true

    @State var day: ScheduleDay
    var todayValue: ScheduleDay {
        let todayDay = today.weekday.dayOfWeek ?? .monday
        return ScheduleDay(week: manager.currentSchedule.currentWeek%2 == 0 ? .even : .odd,
                           day: todayDay)
    }

    var isCurrentDay: Bool {
        // if the day of week is nil, its always false.
        guard today.weekday.dayOfWeek != nil else { return false }
        return day.description == todayValue.description
    }

    var todayView: some View {
        Section {
            DayPickerView(selection: $day, schedule: manager.currentSchedule, today: todayValue)
                .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
            // leading things
            if indexOfCurrentSubject(day: day) > 3 && compactTop {
                HStack {
                    HStack {
                        ForEach(0..<min(3, indexOfCurrentSubject(day: day) - 3), id: \.self) { index in
                            manager.currentSchedule.subjectsMatching(day: day.day, week: day.week)[index]
                                .displayColor
                                .frame(width: 10, height: 25)
                                .cornerRadius(5)
                        }
                    }
                    .mask(alignment: .leading) {
                        LinearGradient(stops: [
                            .init(color: .white, location: 0.2),
                            .init(color: .clear, location: 1)
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
                .onTapGesture {
                    withAnimation {
                        compactTop = false
                    }
                }
                .listRowInsets(.init(top: 5,
                                     leading: 8,
                                     bottom: 5,
                                     trailing: 8))
                .listRowSeparator(.hidden)
            }
            ForEach(Array(manager.currentSchedule.subjectsMatching(day: day.day,
                                                            week: day.week).enumerated()),
                    id: \.0) { (index, subject) in
                if indexOfCurrentSubject(day: day) - index <= 3 || !compactTop {
                    viewForSubject(subject: subject)
                }
            }
            if settings.debugMode {
                HStack {
                    Button("Less") {
                        offsetAmount -= 1
                        self.today = .now.addingTimeInterval(Double(offsetAmount * 60 * 20))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Text("\(offsetAmount), \(today.formatted(date: .omitted, time: .shortened))")
                    Spacer()
                    Button("More") {
                        offsetAmount += 1
                        self.today = .now.addingTimeInterval(Double(offsetAmount * 60 * 20))
                    }
                    .buttonStyle(.plain)
                }
            }
        } header: {
            HStack {
                if today.weekday.dayOfWeek == nil {
                    Text("Next week: W\(manager.currentSchedule.currentWeek+1)")
                } else {
                    Text("W\(manager.currentSchedule.currentWeek), \(today.weekday.rawValue.firstLetterUppercase)")
                }
                Spacer()
                NavigationLink(isActive: $showProvideSchedule) {
                    ProvideScheduleView(showProvideSuggestion: $showProvideSchedule)
                } label: {
                    EmptyView()
                }
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
                OtherSubjectInstancesView(schedule: manager.currentSchedule, subClass: subject.subjectClass)
            }
            .overlay {
                NavigationLink {
                    OtherSubjectInstancesView(schedule: manager.currentSchedule,
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
                    OtherSubjectInstancesView(schedule: manager.currentSchedule,
                                              subClass: subject.subjectClass,
                                              showVisualiser: true)
                } label: {}.opacity(0)
            }
            .listRowSeparator(.hidden)
        }
    }

    func indexOfCurrentSubject(day: ScheduleDay) -> Int {
        guard isCurrentDay else { return -1 }

        let subjects = manager.currentSchedule.subjectsMatching(day: day.day, week: day.week)
        let todayTime = today.timePoint

        // during available subjects
        if let index = subjects.firstIndex(where: { $0.contains(time: todayTime) }) {
            return index
        }

        // before start
        if let start = subjects.first?.timeRange.lowerBound, start > todayTime {
            return -1
        }

        // after end
        if let end = subjects.last?.timeRange.upperBound, end < todayTime {
            return subjects.count
        }

        // default to before start
        return -1
    }
}
