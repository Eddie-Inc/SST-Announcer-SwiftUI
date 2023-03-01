//
//  TimeBlock.swift
//  
//
//  Created by Kai Quan Tay on 23/2/23.
//

import SwiftUI

public protocol TimeBlock: Identifiable, Equatable {
    var day: Day { get }
    var timeBlocks: Range<Int> { get set }

    var displayName: Name? { get }
    var displaySubtext: String? { get }
    var displayColor: Color? { get }

    var displaySubjectClass: SubjectClass? { get set }
}

public extension TimeBlock {
    /// Returns the estimated time range for the subject given the start time
    /// in military time. Eg 4:30pm is 1630
    /// - Parameter startingAt: The time to start at, in military time
    /// - Returns: A tuple, containing the start and end time in military time
    func estimatedTimeRange(startingAt: Int = 0800) -> (Int, Int) {
        let lower = timeBlocks.lowerBound-1
        let upper = timeBlocks.upperBound-1
        let first = startingAt + (100*Int(lower/3)) + 20*(lower%3)
        let second = startingAt + (100*Int(upper/3)) + 20*(upper%3)
        return (first, second)
    }

    /// A textual representation of the ``estimatedTimeRange(startingAt:)``
    func timeRangeDescription(startingAt: Int = 0800) -> String {
        "\(estimatedTimeRange().0.description) - \(estimatedTimeRange().1.description)"
    }

    /// If the given time block is invalid
    var isInvalid: Bool {
        return displaySubjectClass == nil
    }

    /// A formatted version of the duration, eg "1h" for one hour
    func durationFormatted(minutesPerBlock: Int = 20) -> String {
        let totalMinutes = minutesPerBlock * timeBlocks.count
        let hours = totalMinutes / 60
        let minutes = totalMinutes - (hours * 60)

        var formattedString = ""
        if hours > 0 {
            formattedString += hours.description + "hr"
        }
        if minutes > 0 {
            formattedString += minutes.description + "m"
        }

        return formattedString
    }

    /// If the time block contains another time, eg. one ranging 1220 to 0100 contains 1234 but not 1111.
    func contains(time: Int) -> Bool {
        let timeRange = self.estimatedTimeRange()
        return timeRange.0 <= time && time <= timeRange.1
    }
}

public extension Array where Element: TimeBlock {
    /// The number of invalid suggestions in the array
    var invalidSuggestions: Int {
        self.filter({ $0.isInvalid }).count
    }
}
