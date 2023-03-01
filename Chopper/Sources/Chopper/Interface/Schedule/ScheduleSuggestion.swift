//
//  ScheduleSuggestion.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 15/2/23.
//

import SwiftUI

public struct ScheduleSuggestion: ScheduleProvider {

    public var id = UUID()

    public var sourceImage: UIImage
    public var subjects: [SubjectSuggestion] = []
    public var processedSource: SubjectSuggestion
    public var timeRange: Range<Int> { processedSource.timeBlocks }
    public var startDate: Date
    public var repetitions: Int

    public var subjectClasses: [SubjectClass] = []

    public init?(sourceImage: UIImage) {
        self.sourceImage = sourceImage

        // load the subjects
        guard let subjects = try? sourceImage.chop() else { return nil }
        self.processedSource = subjects[0]
        self.subjects = Array(subjects[1...]) // the first one is the debug image

        self.startDate = .now
        self.repetitions = 10
    }
}
