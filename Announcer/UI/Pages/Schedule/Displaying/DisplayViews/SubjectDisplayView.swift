//
//  SubjectDisplayView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 24/2/23.
//

import SwiftUI
import Chopper

struct SubjectDisplayView: View {
    @State var today: Date
    @State var subject: Subject

    @State var allowShowingAsCurrent: Bool = true

    var body: some View {
        ZStack(alignment: .leading) {
            subject.displayColor
                .opacity(0.5)
                .cornerRadius(7)

            HStack {
                subject.displayColor
                    .frame(width: nowInSubject(subject: subject) ? 20 : 10)
                    .cornerRadius(5)
                    .padding(.trailing, -3)
                    .opacity(nowInSubject(subject: subject) ? 1 : 0.5)
                    .padding(5)
                HStack {
                    VStack(alignment: .leading) {
                        Text(subject.displayName!.description)
                            .bold()
                            .lineLimit(1)
                            .padding(.top, subject.subjectClass.teacher == nil ? 5 : 0)
                        if let teacher = subject.subjectClass.teacher {
                            Text(teacher)
                                .lineLimit(1)
                        } else {
                            Spacer()
                        }
                    }
                    .padding(.vertical, 5)
                    Spacer()

                    VStack {
                        Spacer()
                        Text(subject.durationFormatted())
                            .bold()
                        Spacer()
                    }

                    VStack(alignment: .trailing) {
                        Text(subject.estimatedTimeRange().0.description)
                        Text(subject.estimatedTimeRange().1.description)
                    }
                    .frame(width: 40)
                    .padding(5)
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 1)
        .padding(.horizontal, -15)
        .listRowSeparator(.hidden)
    }

    func nowInSubject(subject: Subject) -> Bool {
        let timeRange = subject.estimatedTimeRange()
        return timeRange.0 <= today.formattedTime && today.formattedTime <= timeRange.1 && allowShowingAsCurrent
    }
}

struct SubjectDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SubjectDisplayView(today: .now,
                               subject: .init(timeBlocks: 1..<5,
                                              day: .init(week: .one, day: .monday),
                                              subjectClass:
                                    .init(name: .some("Test"),
                                          color: .blue)))
            SubjectDisplayView(today: .now,
                               subject: .init(timeBlocks: 1..<5,
                                              day: .init(week: .one, day: .monday),
                                              subjectClass:
                                    .init(name: .some("ABCD"),
                                          teacher: "ababa",
                                          color: .purple)))
        }
    }
}
