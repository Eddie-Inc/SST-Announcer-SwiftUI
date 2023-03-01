//
//  ScheduleProvider.swift
//  
//
//  Created by Kai Quan Tay on 23/2/23.
//

import SwiftUI

public protocol ScheduleProvider: Identifiable, Equatable {
    associatedtype Block: TimeBlock

    var subjects: [Block] { get set }
    var subjectClasses: [SubjectClass] { get set }
    var timeRange: Range<Int> { get }
    var startDate: Date { get set }
    var repetitions: Int { get set }

    mutating func deleteClass(subClass: SubjectClass)
}
