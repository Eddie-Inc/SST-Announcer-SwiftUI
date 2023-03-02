//
//  ScheduleProvider+ClassActions.swift
//  
//
//  Created by Kai Quan Tay on 1/3/23.
//

import SwiftUI

public extension ScheduleProvider {
    /// Default implementation of `updateClass(subClass: SubjectClass)`
    mutating func updateClass(subClass: SubjectClass) {
        guard let firstIndex = subjectClasses.firstIndex(where: { $0.id == subClass.id }) else { return }

        subjectClasses[firstIndex] = subClass
        for index in (0..<subjects.count).filter({ subjects[$0].displaySubjectClass?.id == subClass.id }) {
            subjects[index].displaySubjectClass = subClass
        }
    }

    /// Default implementation of `trimUnusedClasses()`
    mutating func trimUnusedClasses() {
        let subjects = subjects
        self.subjectClasses.removeAll { elem in
            !subjects.contains(where: { $0.displaySubjectClass == elem })
        }
    }

    /// Default implementation of `sortClasses()`
    mutating func sortClasses() {
        self.subjects.sort { first, second in
            // check if the week is different
            if first.day.week != second.day.week {
                let firstIndex = Week.allCases.firstIndex(of: first.day.week)!
                let secondIndex = Week.allCases.firstIndex(of: second.day.week)!
                return firstIndex < secondIndex
            }
            // week is the same, check if day is different
            if first.day.day != second.day.day {
                let firstIndex = DayOfWeek.allCases.firstIndex(of: first.day.day)!
                let secondIndex = DayOfWeek.allCases.firstIndex(of: second.day.day)!
                return firstIndex < secondIndex
            }
            // day and week are the same, sort by time (we go by start of subject)
            return first.timeBlocks.lowerBound < second.timeBlocks.lowerBound
        }
    }

    /// Default implementation of `colorFor(name: String) -> Color`
    func colorFor(name: String) -> Color {
        let defaultColors: [[String]: Color] = [
            // core subjects
            ["cl", "hcl", "tl", "htl", "ml"]: .purple,
            ["math"]: .orange,
            ["english", "el"]: .cyan,

            // science
            [
                "science", "sci",
                "phy", "physics",
                "bio", "biology",
                "chem", "chemistry"
            ]: .red,

            // humanities
            ["ss", "social studies"]: .green,
            [
                "geography", "ch(ge)", "ge", "geog",
                "history", "hist"
            ]: .brown,

            // non-graded
            ["s&w"]: .pink,
            ["break"]: .init(white: 0.9),

            // AS
            ["comp", "computing"]: .mint,
            ["electronics", "elec"]: .gray,
            ["biotech", "biot", "bt"]: .indigo,
            ["ds", "design studies"]: .init(white: 0.5)
        ]

        let lowerName = name.lowercased()

        for (names, color) in defaultColors where names.contains(where: { possibleName in
            if possibleName.count <= 2 { // so that "Elec" isn't matched to "EL"
                return lowerName == possibleName
            } else {
                return lowerName.contains(possibleName)
            }
        }) {
            return color
        }

        return .accentColor
    }
}
