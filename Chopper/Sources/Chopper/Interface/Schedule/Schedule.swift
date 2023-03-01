//
//  Schedule.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 21/2/23.
//

import Foundation

/// A data structure representing a timetable, containing subjects, classes, and other scheduling information.
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

    /// Trims unused classes. It is not possible to delete classes here, so it assumes that this function
    /// is being called as clean-up after it has been removed completely.
    public mutating func deleteClass(subClass: SubjectClass) {
        self.trimUnusedClasses()
    }
}
