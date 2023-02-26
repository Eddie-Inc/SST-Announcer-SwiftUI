//
//  Subject.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 15/2/23.
//

import SwiftUI

public struct Subject: TimeBlock, Codable {
    public var timeBlocks: Range<Int>
    public var day: Day

    public var subjectClass: SubjectClass
    public var displaySubjectClass: SubjectClass? {
        get {
            subjectClass
        }
        set {
            if let newValue {
                subjectClass = newValue
            }
        }
    }

    public var id = UUID()

    public init(from suggestion: SubjectSuggestion) {
        guard let subClass = suggestion.subjectClass else { fatalError("Suggestion must have a class") }
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

    public var displayName: Name? { subjectClass.name }
    public var displaySubtext: String? { subjectClass.teacher }
    public var displayColor: Color? { subjectClass.color }
}
