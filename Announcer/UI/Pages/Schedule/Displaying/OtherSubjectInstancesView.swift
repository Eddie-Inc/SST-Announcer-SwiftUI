//
//  OtherSubjectInstancesView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 24/2/23.
//

import SwiftUI
import Chopper

struct OtherSubjectInstancesView: View {
    @State var schedule: Schedule
    @State var subClass: SubjectClass

    @State var showVisualiser: Bool
    @State var strippedSchedule: Schedule

    init(schedule: Schedule, subClass: SubjectClass, showVisualiser: Bool = false) {
        self._schedule = State(wrappedValue: schedule)
        self._subClass = State(wrappedValue: subClass)
        self._showVisualiser = State(wrappedValue: showVisualiser)

        var strippedSchedule = schedule
        if showVisualiser {
            strippedSchedule.subjects = strippedSchedule.subjects.map { subject in
                var mutableSubject = subject
                if subject.subjectClass != subClass {
                    mutableSubject.subjectClass.color = .listBackground
                }
                return mutableSubject
            }
        }
        self._strippedSchedule = State(wrappedValue: strippedSchedule)
    }

    var body: some View {
        List {
            if showVisualiser {
                Section {
                    ScheduleVisualiserView(scheduleSuggestion: strippedSchedule)
                }
            }

            ForEach(validDays) { day in
                viewForday(day: day)
            }
        }
        .navigationTitle(subClass.name.description)
    }

    var validDays: [ScheduleDay] {
        var days: [ScheduleDay] = []
        for week in Week.allCases {
            for day in DayOfWeek.allCases where strippedSchedule.subjectsMatching(day: day, week: week)
                .contains(where: { $0.subjectClass == subClass }) {
                days.append(ScheduleDay(week: week, day: day))
            }
        }

        return days.sorted { first, second in
            schedule.daysUntil(day: first) < schedule.daysUntil(day: second)
        }
    }

    @ViewBuilder
    func viewForday(day: ScheduleDay) -> some View {
        Section {
            ForEach(subjectsForDay(day: day)) { subject in
                SubjectDisplayView(today: .now,
                                   subject: subject,
                                   allowShowingAsCurrent: subject.day.week
                    .matches(weekNo: schedule.currentWeek) &&
                                   subject.day.day == Date().weekday.dayOfWeek)
            }
        } header: {
            HStack {
                Text("\(schedule.dateOfNext(day: day).dayMonthFormat) \(day.description)")
                Spacer()
                if schedule.daysUntil(day: day) == 0 {
                    Text("Today")
                } else {
                    Text("In \(schedule.daysUntil(day: day)) days")
                }
            }
        }
    }

    func subjectsForDay(day: ScheduleDay) -> [Subject] {
        strippedSchedule.subjectsMatching(day: day.day,
                                          week: day.week).filter({
            $0.subjectClass == subClass
        })
    }
}
