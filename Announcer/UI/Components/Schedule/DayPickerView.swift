//
//  DayPickerView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 1/3/23.
//

import SwiftUI
import Chopper
import Updating

struct DayPickerView: View {
    @Binding var selection: Day
    @Updating var schedule: Schedule

    var body: some View {
        GeometryReader { _ in
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    ForEach(Array(sortedDays.enumerated()), id: \.element.id) { index, day in
                        Button {
                            withAnimation {
                                selection = day
                            }
                        } label: {
                            ZStack {
                                if selection == day {
                                    Color.blue
                                        .frame(width: 30, height: 30)
                                        .cornerRadius(15)
                                } else {
                                    Color.gray
                                        .frame(width: 30, height: 30)
                                        .cornerRadius(15)
                                }
                                Text("\(index)")
                            }
                        }
                        .foregroundColor(.background)
                    }
                }
            }
        }
    }

    var sortedDays: [Day] {
        // create all possible days, then sort them
        var days: [Day] = []
        for week in Week.allCases {
            for day in DayOfWeek.allCases {
                days.append(.init(week: week, day: day))
            }
        }
        return days.sorted { first, second in
            schedule.daysUntil(day: first) < schedule.daysUntil(day: second)
        }
    }
}
