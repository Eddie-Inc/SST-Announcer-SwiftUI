//
//  WeekSubjectsView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 25/2/23.
//

import SwiftUI
import Updating
import Chopper

struct WeekSubjectsView<Table: ScheduleProvider, Block: TimeBlock>: View where Block == Table.Block {
    @Binding var scheduleSuggestion: Table
    @Updating var week: Week

    init(schedule: Binding<Table>, week: Week) {
        self._scheduleSuggestion = schedule
        self._week = <-week
    }

    var body: some View {
        ForEach(DayOfWeek.allCases) { day in
            DisclosureGroup {
                viewForDay(day: day)
            } label: {
                headerForDay(day: day)
            }
        }
    }

    @ViewBuilder
    func viewForDay(day: DayOfWeek) -> some View {
        ForEach($scheduleSuggestion.subjects) { $subject in
            if subject.day == .init(week: week, day: day) {
                NavigationLink {
                    SubjectSuggestionEditView(suggestion: $subject,
                                              schedule: $scheduleSuggestion)
                } label: {
                    viewForSubject(subject: subject)
                }
            }
        }
        .onDelete { indexSet in
            scheduleSuggestion.subjects.remove(atOffsets: indexSet)
            // remove all subject classes that no longer exist
            scheduleSuggestion.trimUnusedClasses()
        }
        HStack {
            Spacer()
            Button {
                newSubject(day: day)
            } label: {
                Image(systemName: "plus")
            }
            Spacer()
        }
    }

    func headerForDay(day: DayOfWeek) -> some View {
        HStack {
            Text(day.rawValue.firstLetterUppercase)
            Spacer()
            if scheduleSuggestion.loadProgress == .loaded &&
                scheduleSuggestion.subjects.filter({
                    $0.day == .init(week: week, day: day)
                }).invalidSuggestions > 0 {
                Text(
"\(scheduleSuggestion.subjects.filter({ $0.day == .init(week: week, day: day) }).invalidSuggestions)"
                )
                Image(systemName: "exclamationmark.triangle")
            }
        }
    }

    @ViewBuilder
    // swiftlint:disable:next function_body_length
    func viewForSubject(subject: Block) -> some View {
        if let name = subject.displayName {
            if name.isInvalid && subject.displaySubjectClass == nil {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Subject is unidentifiable! Please manually enter details.")
                    }
                    .foregroundColor(.red)
                    Text(subject.timeRangeDescription)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            } else {
                VStack(alignment: .leading) {
                    HStack {
                        ZStack(alignment: .leading) {
                            if let subClass = subject.displaySubjectClass {
                                subClass.color
                            } else {
                                Color.background
                            }
                        }
                        .frame(width: 24, height: 24)
                        .cornerRadius(12)
                        if let subClass = subject.displaySubjectClass {
                            Text(
"\(subClass.name.description)\(subClass.teacher == nil ? "" : " - \(subClass.teacher ?? "")")"
                            )
                        } else {
                            // "name" if only name, "name - teacher" if has teacher
                            Text(
"\(name.description)\(subject.displaySubtext == nil ? "" : " - \(subject.displaySubtext ?? "")")"
)
                        }
                    }
                    Text(subject.timeRangeDescription)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        } else {
            Text("Loading...")
        }
    }

    func newSubject(day: DayOfWeek) {
        let thisDaySubjects = scheduleSuggestion.subjects.filter({
            $0.day == .init(week: week, day: day)
        })
        let timeLowerRange = thisDaySubjects.last?.timeRange.upperBound ?? .startTime
        guard timeLowerRange < scheduleSuggestion.timeRange.upperBound else {
            // cannot create a subject here
            return
        }
        let timeUpperRange = min(timeLowerRange.addingBlocks(blocks: 3),
                                 scheduleSuggestion.timeRange.upperBound.addingBlocks(blocks: -1))
        let newTimeRange = timeLowerRange..<timeUpperRange

        // create a blank subject
        var newSubject: Block?
        if Block.self == Subject.self {
            newSubject = Subject(timeRange: newTimeRange,
                                 day: .init(week: week, day: day),
                                 subjectClass: .init(name: .some("Untitled"), color: .gray))
            as? Block
        } else if Block.self == SubjectSuggestion.self {
            newSubject = SubjectSuggestion(image: .init(systemName: "questionmark.square")!,
                                           timeRange: newTimeRange,
                                           name: .unidentified,
                                           day: .init(week: week, day: day))
            as? Block
        }

        guard let newSubject else {
            // Failed to create new subject
            return
        }

        scheduleSuggestion.subjects.append(newSubject)
        scheduleSuggestion.sortClasses()
    }
}
