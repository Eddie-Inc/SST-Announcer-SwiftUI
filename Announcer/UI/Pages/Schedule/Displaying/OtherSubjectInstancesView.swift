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

            Section {
                ForEach(Array(validDays.enumerated()), id: \.1.id) { (index, day) in
                    viewForday(day: day)
                        .padding(.bottom, index == validDays.count-1 ? 5 : 0)
                }
            }
        }
        .navigationTitle(subClass.name.description)
    }

    var validDays: [Day] {
        var days: [Day] = []
        for week in Week.allCases {
            for day in DayOfWeek.allCases where strippedSchedule.subjectsMatching(day: day, week: week)
                .contains(where: { $0.subjectClass == subClass }) {
                days.append(Day(week: week, day: day))
            }
        }

        return days
    }

    func viewForday(day: Day) -> some View {
        VStack(alignment: .leading) {
            Text(day.description)
                .font(.caption)
                .foregroundColor(.gray)
                .offset(y: 5)
            ForEach(subjectsForDay(day: day)) { subject in
                SubjectDisplayView(today: .now,
                                   subject: subject,
                                   allowShowingAsCurrent: subject.day.week
                    .matches(weekNo: schedule.currentWeek) &&
                                   subject.day.day == Date().weekday.dayOfWeek)
            }
        }
        .padding(.bottom, -5)
        .listRowSeparator(.hidden)
    }

    func subjectsForDay(day: Day) -> [Subject] {
        strippedSchedule.subjectsMatching(day: day.day,
                                          week: day.week).filter({
            $0.subjectClass == subClass
        })
    }
}
