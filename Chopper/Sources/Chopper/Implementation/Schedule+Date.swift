//
//  Schedule+Date.swift
//  
//
//  Created by Kai Quan Tay on 24/2/23.
//

import SwiftUI

public extension ScheduleProvider {
    /// The date that the schedule is due to end at.
    /// Equal to `startDate` + `repetitions` weeks.
    /// After and including this date, the schedule will be considered invalid.
    var endDate: Date {
        let oneWeek: Double = 60 * 60 * 24 * 7
        return startDate.addingTimeInterval(oneWeek * Double(repetitions) * 2)
    }

    /// If `Date.now` is betwen `startDate` and `endDate`
    var nowInRange: Bool {
        startDate.timeIntervalSince1970 <= Date.now.timeIntervalSince1970 &&
        Date.now.timeIntervalSince1970 <= endDate.timeIntervalSince1970
    }

    /// The current week of the schedule. It will be between 1 and `repetitions` x 2, or -1 if ``nowInRange`` is false.
    var currentWeek: Int {
        guard nowInRange else { return -1 }
        let weeks = Date().timeIntervalSince(startDate) / (60 * 60 * 24 * 7)
        // round it up. Eg the first monday has a miniscule time interval, but is still W1
        return Int(ceil(weeks))
    }

    /// Sets the start date of the schedule to a monday
    mutating func fixStartDate() {
        startDate = startDate.previous(.saturday, considerToday: true)
    }

    /// Returns the number of days until a specific `Day`
    func daysUntil(day: ScheduleDay) -> Int {
        let currentWeek = currentWeek
        let todayWeek: Week = currentWeek%2 == 0 ? .even : .odd
        let todayDay = Date().weekday.dayOfWeek ?? .monday // default to monday

        let thisDay = ScheduleDay(week: todayWeek, day: todayDay)

        return thisDay.daysFrom(laterDay: day)
    }

    /// Returns a ``Date`` representing the next occurence of a given day.
    /// The time of the returned date is the same as the current time.
    func dateOfNext(day: ScheduleDay) -> Date {
        let days = daysUntil(day: day)
        return Date(timeIntervalSinceNow: Double(days * 60 * 60 * 24))
    }
}

public extension Date {

    /// Gets the next given weekday for this date
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.next,
                   weekday,
                   considerToday: considerToday)
    }

    /// Gets the previous given weekday for this date
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.previous,
                   weekday,
                   considerToday: considerToday)
    }

    /// Gets the previous or next given weekday for this date
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {

        let dayName = weekDay.rawValue
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }

        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")

        // get the search day and components
        let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1
        let calendar = Calendar(identifier: .gregorian)
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
        nextDateComponent.weekday = searchWeekdayIndex

        // search for it. It should never return nil.
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)

        return date!
    }

    /// Formats it in the format day/month
    var dayMonthFormat: String {
        let components = self.formatted(date: .numeric, time: .omitted).split(separator: "/")
        return components[0..<2].joined(separator: "/")
    }
}

// MARK: Helper methods
public extension Date {
    /// Gets an array of weekdays in english
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }

    /// An enumeration for days of the week. Like ``DayOfWeek``, but including weekends.
    enum Weekday: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday

        /// converted to a DayOfWeek, if possible
        public var dayOfWeek: DayOfWeek? {
            switch self {
            case .monday: return .monday
            case .tuesday: return .tuesday
            case .wednesday: return .wednesday
            case .thursday: return .thursday
            case .friday: return .friday
            default: return nil
            }
        }
    }

    /// The direction to search, either forward or backward
    enum SearchDirection {
        /// search forwards in time
        case next
        /// search backwards in time
        case previous

        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .next:
                return .forward
            case .previous:
                return .backward
            }
        }
    }

    /// The weekday of the date
    var weekday: Weekday {
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
        let calendar = Calendar(identifier: .gregorian)
        // subtract one because the weekday component starts at 1
        let index = calendar.component(.weekday, from: self)-1
        return Weekday(rawValue: weekdaysName[index].lowercased())!
    }

    /// The military time of the date, eg. 4pm is 1600
    var formattedTime: Int {
        let calendar = Calendar(identifier: .gregorian)
        let hours   = calendar.component(.hour, from: self)
        let minutes = calendar.component(.minute, from: self)

        return hours*100 + minutes
    }
}
