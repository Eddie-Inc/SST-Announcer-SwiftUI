//
//  SubjectSuggestion.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 14/2/23.
//

import SwiftUI

public struct SubjectSuggestion: TimeBlock {
    public var image: UIImage

    public var timeBlocks: Range<Int>
    public var day: Day

    public var name: Name?
    public var teacher: String?
    public var rawTextContents: [String]?
    public var subjectClass: SubjectClass?

    public var displaySubjectClass: SubjectClass? {
        get {
            subjectClass
        }
        set {
            subjectClass = newValue
        }
    }

    public init(image: UIImage,
                timeBlocks: Range<Int>,
                name: Name? = nil,
                teacher: String? = nil,
                day: Day) {
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
            self.day = .init(week: .one, day: .monday)
        }
    }

    // MARK: Identifiable
    public var id = UUID()

    public var displayName: Name? { subjectClass?.name ?? name }
    public var displaySubtext: String? { subjectClass?.teacher ?? teacher }
    public var displayColor: Color? { subjectClass?.color }
}
