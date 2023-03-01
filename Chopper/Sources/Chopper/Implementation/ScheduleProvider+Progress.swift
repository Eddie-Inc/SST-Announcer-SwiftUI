//
//  ScheduleProvider+Progress.swift
//  
//
//  Created by Kai Quan Tay on 1/3/23.
//

import Foundation

public extension ScheduleProvider {
    /// The progress of the loading, as a ``LoadProgress``
    var loadProgress: LoadProgress {
        if loadedSubjects == 0 { return .unloaded }
        if loadedSubjects == subjects.count { return .loaded }
        return .loading
    }

    /// The number of loaded subjects
    var loadedSubjects: Int {
        subjects.filter({ $0.displayName != nil }).count
    }

    /// The decimal representing the proportion of loaded subjects
    var loadAmount: Double {
        Double(loadedSubjects) / Double(subjects.count)
    }

    /// If the subject is unreadable, or does not have a class
    var invalidSuggestions: Int {
        subjects.invalidSuggestions
    }

    /// Returns the subjects matching a day and a week. If the week is even, it uses the even timetable.
    /// If it is odd, it uses the odd timetable.
    func subjectsMatching(day: DayOfWeek, week: Int) -> [Block] {
        return subjects.filter { subject in
            subject.day.day == day && subject.day.week.matches(weekNo: week)
        }
    }

    /// Returns the subjects matching a day and a week.
    func subjectsMatching(day: DayOfWeek, week: Week) -> [Block] {
        return subjects.filter { subject in
            subject.day.day == day && subject.day.week == week
        }
    }
}
