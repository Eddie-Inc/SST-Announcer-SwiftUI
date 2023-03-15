//
//  TimeTableSmall.swift
//  Announcer
//
//  Created by Kai Quan Tay on 7/3/23.
//

import SwiftUI
import Chopper
import Updating

struct TimeTableSmall: TimeTableProtocol {
    @ObservedObject
    var manager: ScheduleManager = .default

    @Updating
    var today: Date

    // FOR DEBUG PURPOSES ONLY
    @State
    var message: String = ""

    init(today: Date) {
        self._today = <-today
        ScheduleManager.default.fetchSchedules()
    }

    var body: some View {
        ZStack {
            if let currentSchedule = manager.currentSchedule {
                VStack(alignment: .leading) {
                    Text("W\(currentSchedule.currentWeek), \(today.weekday.rawValue.firstLetterUppercase). \(indexOfCurrentSubject())")
                    if indexOfCurrentSubject() < todaySubjects.count {
                        subjectsView
                        otherSubjectsView
                    } else {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("No more subjects!")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            } else {
                Text("No Schedule Found")
            }
        }
        .padding(12)
    }

    var subjectsView: some View {
        // NOTE: Fix index out of bounds error that sometimes happens here.
        ForEach(0..<max(0, min(3, todaySubjects.count-indexOfCurrentSubject())), id: \.self) { index in
            viewForSubject(subject: todaySubjects[indexOfCurrentSubject()+index], isCurrent: index == 0)
                .padding(.vertical, -2)
        }
    }

    // TODO: Get this working
    var otherSubjectsView: some View {
        HStack {
            ForEach([Color.red, Color.blue, Color.green], id: \.self) { color in
                color
                    .cornerRadius(3)
                    .frame(width: 6, height: 6)
                    .padding(.horizontal, -2)
            }
            Text("3 More")
                .font(.caption)
        }
        .padding(.leading, 2)
        .frame(height: 10)
    }

    @ViewBuilder
    func viewForSubject(subject: Subject, isCurrent: Bool) -> some View {
        if isCurrent {
            ZStack {
                (subject.displayColor ?? .accentColor)
                    .cornerRadius(4)
                    .opacity(0.5)
                HStack {
                    (subject.displayColor ?? .accentColor)
                        .frame(width: 6)
                        .cornerRadius(3)
                        .padding(3)
                        .padding(.trailing, -4)

                    HStack {
                        Text(subject.displayName?.description ?? "Unnamed")
                            .font(.caption)
                        Spacer()
                        Text(subject.durationFormatted)
                            .font(.caption2)
                    }
                    .padding(.horizontal, 5)
                }
            }
            .padding(.leading, -3)
        } else {
            HStack {
                (subject.displayColor ?? .accentColor)
                    .frame(width: 6)
                    .cornerRadius(3)
                    .padding(.trailing, -4)
                ZStack(alignment: .leading) {
                    (subject.displayColor ?? .accentColor)
                        .cornerRadius(4)
                        .opacity(0.2)

                    HStack {
                        Text(subject.displayName?.description ?? "Unnamed")
                            .font(.caption)
                        Spacer()
                        Text(subject.durationFormatted)
                            .font(.caption2)
                    }
                    .padding(.horizontal, 5)
                }
            }
        }
    }
}

struct TimeTableSmall_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableSmall(today: .now)
            .frame(width: 155, height: 155)
            .border(.black, width: 1)
    }
}
