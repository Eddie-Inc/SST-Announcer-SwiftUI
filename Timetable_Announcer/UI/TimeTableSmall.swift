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
        ScheduleManager.default.fetchSchedule()
    }

    var body: some View {
        ZStack {
            if manager.currentSchedule != nil {
                VStack(alignment: .leading) {
                    Text("W\(manager.schedule.currentWeek), \(today.weekday.rawValue.firstLetterUppercase)")
                    ForEach(0..<3) { index in
                        HStack {
                            (todaySubjects[index].displayColor ?? .accentColor)
                                .frame(width: 6)
                                .cornerRadius(3)
                                .padding(.trailing, -4)
                            ZStack(alignment: .leading) {
                                (todaySubjects[index].displayColor ?? .accentColor)
                                    .cornerRadius(4)
                                    .opacity(0.3)
                                HStack {
                                    Text(todaySubjects[index].displayName?.description ?? "Unnamed")
                                        .font(.caption)
                                    Spacer()
                                    Text(todaySubjects[index].durationFormatted)
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 5)
                            }
                        }
                        .padding(.vertical, -2)
                    }
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
            } else {
                Text("No Schedule Found")
            }
        }
        .padding(12)
    }
}

struct TimeTableSmall_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableSmall(today: .now)
            .frame(width: 155, height: 155)
            .border(.black, width: 1)
    }
}
