//
//  ScheduleProvider.swift
//  
//
//  Created by Kai Quan Tay on 23/2/23.
//

import SwiftUI

/// An abstraction of ``Schedule`` and ``ScheduleSuggestion``
public protocol ScheduleProvider: Identifiable, Equatable {
    associatedtype Block: TimeBlock

    /// The name of the schedule
    var name: String? { get set }

    /// The subjects in the Schedule
    var subjects: [Block] { get set }
    /// The classes for the ``subjects``
    var subjectClasses: [SubjectClass] { get set }
    /// The time range in the schedule.
    /// The range contains the time range of every item in ``subjects``. It may not be an exact fit, it could be larger.
    var timeRange: TimeRange { get }

    /// The date that this schedule is intended to start.
    var startDate: Date { get set }
    /// The number of times this schedule repeats. 10 weeks means 5 repetitions of the 2 week cycle.
    var repetitions: Int { get set }

    /// Deletes a class from the schedule. Usually involves removing the class from items in ``subjects``.
    mutating func deleteClass(subClass: SubjectClass)

    // MARK: With default implementations
    /// Update the values of the `subjectClass` of the ``subjects``, where the ids match.
    mutating func updateClass(subClass: SubjectClass, sender: Block?)
    /// Removes unused classes
    mutating func trimUnusedClasses()
    /// Sorts subjects by day, then time
    mutating func sortClasses()
    /// Gets the color for a given subject name
    func colorFor(name: String) -> Color
}
