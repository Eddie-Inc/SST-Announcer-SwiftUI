//
//  DayOfWeek.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 21/2/23.
//

import Foundation

public enum DayOfWeek: String, CaseIterable, Equatable, Identifiable, Codable {
    case monday, tuesday, wednesday, thursday, friday
    public var id: String { self.rawValue }

    var number: Int {
        switch self {
        case .monday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thursday: return 3
        case .friday: return 4
        }
    }
}

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

public struct Day: Equatable, Identifiable, Codable {
    public var week: Week
    public var day: DayOfWeek

    public var description: String {
        let dayString = day.rawValue.firstLetterUppercase
        return "\(dayString), \(week == .odd ? "Odd" : "Even") Week"
    }
    public var id: String { description }

    public init(week: Week, day: DayOfWeek) {
        self.week = week
        self.day = day
    }

    func daysFrom(laterDay: Day) -> Int {
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
