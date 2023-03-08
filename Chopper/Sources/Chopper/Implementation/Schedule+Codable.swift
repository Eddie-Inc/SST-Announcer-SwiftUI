//
//  Schedule+Codable.swift
//  
//
//  Created by Kai Quan Tay on 8/3/23.
//

import Foundation

extension Schedule: Codable {
    enum Keys: CodingKey {
        case id
        case subjects
        case subjectClasses
        case timeRange
        case startDate
        case repetitions
    }

    struct SubjectDecoder: Codable {
        var classID: Int
        var day: ScheduleDay
        var timeRange: TimeRange

        init(from subject: Subject, classes: [SubjectClass]) {
            self.classID = classes.firstIndex(of: subject.subjectClass)!
            self.day = subject.day
            self.timeRange = subject.timeRange
        }

        enum Keys: CodingKey {
            case classID, day, timeRange
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            self.classID = try container.decode(Int.self, forKey: .classID)
            self.day = try container.decode(ScheduleDay.self, forKey: .day)
            self.timeRange = try container.decode(TimeRange.self, forKey: .timeRange)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Keys.self)

            try container.encode(classID, forKey: .classID)
            try container.encode(day, forKey: .day)
            try container.encode(timeRange, forKey: .timeRange)
        }

        /// Expands this `SubjectDecoder` into a full `Subject`, given the classes.
        func subjectGiven(classes: [SubjectClass]) -> Subject? {
            return .init(timeRange: self.timeRange,
                         day: self.day,
                         subjectClass: classes[classID])
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(id, forKey: .id)
        try container.encode(subjects.map({ SubjectDecoder(from: $0, classes: subjectClasses) }), forKey: .subjects)
        try container.encode(subjectClasses, forKey: .subjectClasses)
        try container.encode(timeRange, forKey: .timeRange)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(repetitions, forKey: .repetitions)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.timeRange = try container.decode(TimeRange.self, forKey: .timeRange)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.repetitions = try container.decode(Int.self, forKey: .repetitions)

        let subjectClasses = try container.decode([SubjectClass].self, forKey: .subjectClasses)
        self.subjectClasses = subjectClasses

        do {
            let subjectDecoders = try container.decode([SubjectDecoder].self, forKey: .subjects)
            self.subjects = subjectDecoders.compactMap { decoder in
                decoder.subjectGiven(classes: subjectClasses)
            }
        } catch {
            // support for legacy encoder
            self.subjects = try container.decode([Subject].self, forKey: .subjects)
        }
    }
}
