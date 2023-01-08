//
//  TimeAndReminder.swift
//  Announcer
//
//  Created by Kai Quan Tay on 6/1/23.
//

import SwiftUI

struct TimeAndReminder: View {
    @Binding
    var post: Post

    var body: some View {
        HStack {
            Image(systemName: "timer")
            Text(formattedDate())
                .padding(.trailing, 10)

            if post.reminderDate != nil {
                Image(systemName: "alarm")
                Text(formattedReminderTime())
            }
        }
    }

    func formattedDate() -> String {
        post.date.formatted(date: .abbreviated, time: .omitted)
    }

    func formattedReminderTime() -> String {
        if let reminderDate = post.reminderDate {
            return Date.now.prettyTimeUntil(laterDate: reminderDate)
        } else {
            return ""
        }
    }
}

extension Date {
    func prettyTimeUntil(laterDate: Date) -> String {
        var interval = laterDate.timeIntervalSince(self)

        var isDue: Bool = false
        // if interval < 0, means that the later date is not actually after self
        if interval < 0 {
            isDue = true
        }
        // if the later date is actually before self, then we will append a "-" sign
        // to the end
        let isDueString = isDue ? "-" : ""
        interval = abs(interval)

        // calculate the ideal unit
        let dateUnit = interval.idealUnit()

        // use the ideal unit to create the resultant string
        let dividedByTime = interval/dateUnit.value
        let rounded = Int(dividedByTime.rounded(.toNearestOrAwayFromZero))
        let plural = rounded == 1 ? "" : "s"
        return "\(isDueString)\(rounded) \(dateUnit.string)\(plural)"
    }
}

extension TimeInterval {
    func idealUnit() -> DateUnit {
        if self > 0, self < DateUnit.hour.value { // 0s to 1 hour is specified in minutes
            return .min
        } else if DateUnit.hour.value <= self, self < DateUnit.day.value { // 1 hour to 1 day is specified in hours
            return .hour
        } else if DateUnit.day.value <= self, self < DateUnit.week.value { // 1 day to 1 week is specified in days
            return .day
        } else if DateUnit.week.value <= self, self < DateUnit.month.value { // 1 week to 1 month is specified in weeks
            return .week
        } else if DateUnit.month.value <= self, self < DateUnit.year.value { // 1 month to 1 year is specified in months
            return .month
        } else if DateUnit.year.value <= self { // 1 year onwards is specified in years
            return .year
        }

        return .hour // default to hour
    }
}

enum DateUnit {
    case min
    case hour
    case day
    case week
    case month
    case year

    var value: Double {
        switch self {
        case .min:
            return 60
        case .hour:
            return 3_600 // 60 * 60
        case .day:
            return 86_400 // 60*60 * 24
        case .week:
            return 604_800 // 60*60*24 * 7
        case .month:
            return 2_629_800 // 60*60*24*365.25 / 12
        case .year:
            return 31_557_600 // 60*60*24 * 365.25
        }
    }

    var string: String {
        switch self {
        case .min: return "min"
        case .hour: return "hr"
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        }
    }
}
