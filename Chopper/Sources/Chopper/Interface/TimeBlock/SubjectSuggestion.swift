//
//  SubjectSuggestion.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 14/2/23.
//

import SwiftUI

/// Represents a suggestion for a subject in a ``ScheduleSuggestion``
public struct SubjectSuggestion: TimeBlock {
    /// A cropped part of a schedule for the subject that this `SubjectSuggestion` represents
    public var image: UIImage
    /// The name of the schedule, if available. Read only externally.
    public internal(set) var name: Name?
    /// The teacher of the schedule, if available. Read only externally.
    public internal(set) var teacher: String?
    /// The raw text that the Vision API returned, if available. Read only externally.
    public internal(set) var rawTextContents: [String]?

    public var day: ScheduleDay
    public var timeBlocks: Range<Int>
    /// A wrapper for `displaySubjectClass.name`, defaulting to ``name``
    public var displayName: Name? { displaySubjectClass?.name ?? name }
    /// A wrapper for `displaySubjectClass.teacher`, defaulting to ``teacher``
    public var displaySubtext: String? { displaySubjectClass?.teacher ?? teacher }
    /// A wrapper for `displaySubjectClass.color`
    public var displayColor: Color? { displaySubjectClass?.color }
    public var displaySubjectClass: SubjectClass?

    public init(image: UIImage,
                timeBlocks: Range<Int>,
                name: Name? = nil,
                teacher: String? = nil,
                day: ScheduleDay) {
        self.image = image
        self.timeBlocks = timeBlocks
        self.name = name
        self.teacher = teacher
        self.day = day
    }

    public init(image: UIImage,
                timeBlocks: Range<Int>,
                rawDay: Int) {
        self.image = image
        self.timeBlocks = timeBlocks
        let day = rawDay%10
        if day < 10 && day >= 0 {
            self.day = .init(week: Week.allCases[rawDay/5], day: DayOfWeek.allCases[rawDay%5])
        } else {
            self.day = .init(week: .odd, day: .monday)
        }
    }

    public var id = UUID()
}
