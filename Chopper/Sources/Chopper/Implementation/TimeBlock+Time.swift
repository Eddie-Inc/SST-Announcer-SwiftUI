//
//  TimeBlock+Time.swift
//  
//
//  Created by Kai Quan Tay on 1/3/23.
//

import Foundation

public extension TimeBlock {
    /// A description of the time range, eg. "0800 - 0840"
    var timeRangeDescription: String {
        "\(timeRange.lowerBound.description) - \(timeRange.upperBound.description)"
    }

    /// A formatted version of the duration, eg "1h" for one hour
    var durationFormatted: String {
        let difference = timeRange.upperBound - timeRange.lowerBound
        let hours = difference.hour
        let minutes = difference.minutes

        var formattedString = ""
        if hours > 0 {
            formattedString += hours.description + "hr"
        }
        if minutes > 0 {
            formattedString += minutes.description + "m"
        }

        return formattedString
    }

    /// Default image
    func contains(time: TimePoint) -> Bool {
        return timeRange.contains(time)
    }
}
