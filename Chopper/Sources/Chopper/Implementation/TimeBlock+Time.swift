//
//  TimeBlock+Time.swift
//  
//
//  Created by Kai Quan Tay on 1/3/23.
//

import Foundation

public extension TimeBlock {
    /// Default implementation of `estimatedTimeRange(startingAt: Int) -> (Int, Int)`
    func estimatedTimeRange(startingAt: Int = 0800) -> (Int, Int) {
        let lower = timeBlocks.lowerBound-1
        let upper = timeBlocks.upperBound-1
        let first = startingAt + (100*Int(lower/3)) + 20*(lower%3)
        let second = startingAt + (100*Int(upper/3)) + 20*(upper%3)
        return (first, second)
    }

    /// Default implementation of `timeRangeDescription(startingAt: Int) -> String`
    func timeRangeDescription(startingAt: Int = 0800) -> String {
        "\(estimatedTimeRange().0.description) - \(estimatedTimeRange().1.description)"
    }

    /// Default implementation of `durationFormatted(minutesPerBlock: Int) -> String`
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

    /// Default implementation of `contains(time: Int) -> Bool`
    func contains(time: Int) -> Bool {
        let timeRange = self.estimatedTimeRange()
        return timeRange.0 <= time && time <= timeRange.1
    }
}
