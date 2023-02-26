//
//  Schedule.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 21/2/23.
//

import Foundation

public struct Schedule: ScheduleProvider, Codable {
    public var id = UUID()

    public var subjects: [Subject]
    public var subjectClasses: [SubjectClass]
    public var timeRange: Range<Int>

    public var startDate: Date
    public var repetitions: Int

    public init(from suggestion: ScheduleSuggestion) {
        self.subjects = suggestion.subjects.map({ Subject(from: $0) })
        self.subjectClasses = suggestion.subjectClasses
        self.timeRange = suggestion.processedSource.timeBlocks
        self.startDate = suggestion.startDate
        self.repetitions = suggestion.repetitions
    }

    /// Since no classes can be unclassed here, just trim unused ones.
    public mutating func deleteClass(subClass: SubjectClass) {
        self.trimUnusedClasses()
    }
}
