//
//  Subject.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 15/2/23.
//

import SwiftUI

/// Represents a subject in a ``Schedule``
public struct Subject: TimeBlock, Codable {
    /// The actual subject class of the subject. Will always be present, unlike ``displaySubjectClass``.
    public var subjectClass: SubjectClass

    public var day: Day
    public var timeBlocks: Range<Int>
    /// A wrapper for `subjectClass.name`
    public var displayName: Name? { subjectClass.name }
    /// A wrapper for `subjectClass.teacher`
    public var displaySubtext: String? { subjectClass.teacher }
    /// A wrapper for `subjectClass.color`
    public var displayColor: Color? { subjectClass.color }
    /// A wrapper for `subjectClass`
    public var displaySubjectClass: SubjectClass? {
        get { subjectClass }
        set {
            guard let newValue else { return }
            subjectClass = newValue
        }
    }

    public init(from suggestion: SubjectSuggestion) {
        guard let subClass = suggestion.displaySubjectClass else { fatalError("Suggestion must have a class") }
        self.timeBlocks = suggestion.timeBlocks

        self.day = suggestion.day
        self.subjectClass = subClass
    }

    public init(timeBlocks: Range<Int>,
                day: Day,
                subjectClass: SubjectClass) {
        self.timeBlocks = timeBlocks
        self.day = day
        self.subjectClass = subjectClass
    }

    public var id = UUID()
}
