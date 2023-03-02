//
//  DayOfWeek.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 21/2/23.
//

import Foundation

/// An enumeration representing weekdays
public enum DayOfWeek: String, CaseIterable, Equatable, Identifiable, Codable {
    case monday, tuesday, wednesday, thursday, friday
    public var id: String { self.rawValue }

    public var number: Int {
        switch self {
        case .monday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thursday: return 3
        case .friday: return 4
        }
    }
}

/// An enumeration representing if a week is even or odd
public enum Week: String, CaseIterable, Equatable, Identifiable, Codable {
    case odd, even
    public var id: String { self.rawValue }

    public init(weekNo: Int) {
        self = (weekNo%2 == 0) ? .even : .odd
    }

    public func matches(weekNo: Int) -> Bool {
        switch self {
        case .odd:
            return weekNo%2 != 0
        case .even:
            return weekNo%2 == 0
        }
    }
}

/// A structure containing a ``DayOfWeek`` and a ``Week``
public struct Day: Equatable, Identifiable, Codable {
    /// The week of the Day
    public var week: Week
    /// The day of the week of the Day
    public var day: DayOfWeek

    /// A textual representation of the Day
    public var description: String {
        let dayString = day.rawValue.firstLetterUppercase
        return "\(dayString), \(week == .odd ? "Odd" : "Even") Week"
    }
    public var id: String { description }

    public init(week: Week, day: DayOfWeek) {
        self.week = week
        self.day = day
    }

    /// The number of days until a certain other day.
    /// If the later day comes "before" `self`, it wraps around and returns the
    /// number of days until it reaches that day again
    public func daysFrom(laterDay: Day) -> Int {
        // if its the same, return 0
        guard laterDay != self else { return 0 }

        if laterDay.week == self.week {
            // same week
            if self.day.number < laterDay.day.number {
                // later day is after current one
                return laterDay.day.number - self.day.number
            } else {
                // later day is "before" the current one. Just add 14 days and subtract the difference.
                return 14 - (self.day.number - laterDay.day.number)
            }
        } else {
            // different week
            let difference = laterDay.day.number - self.day.number
            // return the difference + 7 for one week
            return difference + 7
        }
    }
}

public extension String {
    /// The string, but with the first character capitalised
    var firstLetterUppercase: String {
        let firstLetter = self.prefix(1).capitalized
        let remainingLetters = self.dropFirst().lowercased()
        return firstLetter + remainingLetters
    }
}
