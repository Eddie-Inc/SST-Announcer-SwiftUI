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

    public func loadSubjectTexts(onUpdate: @escaping (ScheduleSuggestion) -> Void) {
        guard self.loadProgress == .unloaded else { return } // make sure not already loaded
        var mutableSelf = self
        for index in 0..<mutableSelf.subjects.count {
            mutableSelf.subjects[index].load { newValue in
                mutableSelf.subjects[index] = newValue
                onUpdate(mutableSelf)
            }
        }
    }

    public mutating func loadClasses() {
        guard self.loadProgress == .loaded else { return } // fully load first

        var mutableSelf = self

        for index in 0..<subjects.count {
            let subject = subjects[index]
            if let identifiedClass = mutableSelf.subjectClasses.first(where: { subClass in
                // if name and teacher are identical, assign it to that class
                subClass.name == subject.name && subClass.teacher == subject.teacher
            }) {
                mutableSelf.subjects[index].subjectClass = identifiedClass
                continue
            }

            guard let name = subject.name else { continue }
            switch name {
            case .some(let string):
                // if it is not invalid, create a class for it
                let newClass = SubjectClass(name: name,
                                            teacher: subject.teacher,
                                            color: colorFor(name: string))
                mutableSelf.subjects[index].subjectClass = newClass
                mutableSelf.subjectClasses.append(newClass)
            default: break
            }
        }

        self = mutableSelf
    }

    /// Removes a certain class
    public mutating func deleteClass(subClass: SubjectClass) {
        // mark all the subjects with this class as no-class
        self.subjectClasses.removeAll(where: { $0.id == subClass.id })
        for index in (0..<subjects.count).filter({ subjects[$0].displaySubjectClass?.id == subClass.id }) {
            subjects[index].displaySubjectClass = nil
        }
    }
}

/// Represents the load progress of a ``ScheduleSuggestion``
public enum LoadProgress {
    /// Hasn't been loaded yet
    case unloaded
    /// Is being loaded
    case loading
    /// Has been loaded
    case loaded
}
