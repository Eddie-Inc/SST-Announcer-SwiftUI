//
//  TimeBlock.swift
//  
//
//  Created by Kai Quan Tay on 23/2/23.
//

import SwiftUI

/// Abstraction for ``Subject`` and ``SubjectSuggestion``
public protocol TimeBlock: Identifiable, Equatable {
    /// The day of the block
    var day: ScheduleDay { get }
    /// The time range of the block
    var timeRange: TimeRange { get set }

    /// What to display as the name of the block. Usually the subject name.
    var displayName: Name? { get }
    /// What to display as the subtext of the block. Usually a teacher name.
    var displaySubtext: String? { get }
    /// The color to display for the block. Usually the subject's folder's color,
    /// but can be overridden by the user.
    var displayColor: Color? { get }
    /// The subject class of the TimeBlock
    var displaySubjectClass: SubjectClass? { get set }

    /// If the time block contains another time, eg. one ranging 1220 to 0100 contains 1234 but not 1111.
    func contains(time: TimePoint) -> Bool
}

extension TimeBlock {
    /// If the given time block is invalid
    var isInvalid: Bool {
        return displaySubjectClass == nil
    }
}

public extension Array where Element: TimeBlock {
    /// The number of invalid suggestions in the array
    var invalidSuggestions: Int {
        self.filter({ $0.isInvalid }).count
    }
}
