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
                ForEach(strippedSchedule.subjects.filter({ $0.subjectClass == subClass })) { subject in
                    VStack(alignment: .leading) {
                        Text(subject.day.description)
                            .font(.subheadline)
                            .offset(y: 5)
                        SubjectDisplayView(today: .now,
                                           subject: subject,
                                           allowShowingAsCurrent: subject.day.week
                                                .matches(weekNo: schedule.currentWeek) &&
                                                subject.day.day == Date().weekday.dayOfWeek)
                    }
                }
            }
        }
        .navigationTitle(subClass.name.description)
    }
}
