//
//  ScheduleSuggestion.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 15/2/23.
//

import SwiftUI

/// A suggestion for a ``Schedule``, containing code for reading from
/// a schedule image and other data to aid user customisation.
public struct ScheduleSuggestion: ScheduleProvider {
    /// The initial image submitted
    public var sourceImage: UIImage
    /// A debug image, derived from the initial submitted image
    public var processedSource: SubjectSuggestion

    public var subjects: [SubjectSuggestion] = []
    public var subjectClasses: [SubjectClass] = []
    public var timeRange: Range<Int> { processedSource.timeBlocks }
    public var startDate: Date
    public var repetitions: Int

    public init?(sourceImage: UIImage) {
        self.sourceImage = sourceImage

        // load the subjects
        guard let subjects = try? sourceImage.chop() else { return nil }
        self.processedSource = subjects[0]
        self.subjects = Array(subjects[1...]) // the first one is the debug image

        self.startDate = .now
        self.repetitions = 10
    }

    public var id = UUID()
}
