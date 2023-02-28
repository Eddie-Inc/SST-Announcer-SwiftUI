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
}

public extension String {
    /// The string, but with the first character capitalised
    var firstLetterUppercase: String {
        let firstLetter = self.prefix(1).capitalized
        let remainingLetters = self.dropFirst().lowercased()
        return firstLetter + remainingLetters
    }
}
