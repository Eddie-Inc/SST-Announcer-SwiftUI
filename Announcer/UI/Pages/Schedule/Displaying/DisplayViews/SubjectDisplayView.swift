//
//  SubjectDisplayView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 24/2/23.
//

import SwiftUI
import Chopper
import Updating

struct SubjectDisplayView: View {
    @State var today: Date
    @Updating var subject: Subject

    @State var allowShowingAsCurrent: Bool = true

    var body: some View {
        ZStack(alignment: .leading) {
            if nowInSubject(subject: subject) {
                HStack {
                    pillShape
                        .padding([.leading, .trailing], 5)
                    ZStack {
                        background
                        mainContent
                            .padding(.leading, 8)
                    }
                }
            } else {
                background
                    .opacity(0.5)
                HStack {
                    pillShape
                        .padding(5)
                    mainContent
                }
            }
        }
        .padding(.vertical, 1)
        .padding(.horizontal, -15)
        .listRowSeparator(.hidden)
    }

    var background: some View {
        ZStack {
            Color.background
            subject.displayColor
                .opacity(0.5)
        }
        .cornerRadius(7)
    }

    var pillShape: some View {
        ZStack {
            subject.displayColor
        }
        .frame(width: 10)
        .cornerRadius(5)
        .opacity(nowInSubject(subject: subject) ? 1 : 0.5)
        .padding(.trailing, -3)
        .padding(.trailing, -3)
    }

    var mainContent: some View {
        HStack {
            if nowInSubject(subject: subject) {
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
            } else {
                HStack {
                    Text(subject.displayName!.description)
                        .bold()
                        .lineLimit(1)
                }
                .padding(.vertical, 5)
            }
            Spacer()

            VStack {
                Spacer()
                Text(subject.durationFormatted())
                    .bold()
                Spacer()
            }

            if nowInSubject(subject: subject) {
                VStack(alignment: .trailing) {
                    Text(subject.estimatedTimeRange().0.description)
                    Text(subject.estimatedTimeRange().1.description)
                }
                .frame(width: 40)
                .padding(5)
            } else {
                HStack {
                    Text(subject.estimatedTimeRange().0.description)
                    Text(subject.estimatedTimeRange().1.description)
                }
                .padding(5)
            }
        }
        .font(.caption)
    }

    // swiftlint:disable:next discouraged_optional_boolean
    var showAsCurrent: Bool?
    func nowInSubject(subject: Subject) -> Bool {
        if let showAsCurrent { return showAsCurrent }

        return subject.contains(time: today.formattedTime) && allowShowingAsCurrent
    }

    // for debug purposes only
    func overrideShowAsCurrent(show: Bool) -> SubjectDisplayView {
        var mutableSelf = self
        mutableSelf.showAsCurrent = show
        return mutableSelf
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
            .overrideShowAsCurrent(show: false)
            SubjectDisplayView(today: .now,
                               subject: .init(timeBlocks: 1..<5,
                                              day: .init(week: .one, day: .monday),
                                              subjectClass:
                                    .init(name: .some("ABCD"),
                                          teacher: "ababa",
                                          color: .purple)))
            .overrideShowAsCurrent(show: false)
            SubjectDisplayView(today: .now,
                               subject: .init(timeBlocks: 1..<5,
                                              day: .init(week: .one, day: .monday),
                                              subjectClass:
                                    .init(name: .some("IDK man"),
                                          color: .brown)))
            .overrideShowAsCurrent(show: true)
            SubjectDisplayView(today: .now,
                               subject: .init(timeBlocks: 1..<5,
                                              day: .init(week: .one, day: .monday),
                                              subjectClass:
                                    .init(name: .some("Quite light"),
                                          teacher: "barayrs",
                                          color: .gray)))
            .overrideShowAsCurrent(show: false)
        }
    }
}
