//
//  TimeBlock.swift
//  
//
//  Created by Kai Quan Tay on 23/2/23.
//

import SwiftUI

public protocol TimeBlock: Identifiable, Equatable {
    var day: Day { get }
    var timeBlocks: Range<Int> { get set }

    var displayName: Name? { get }
    var displaySubtext: String? { get }
    var displayColor: Color? { get }

    var displaySubjectClass: SubjectClass? { get set }
}

public extension Array where Element: TimeBlock {
    /// The number of invalid suggestions in the array
    var invalidSuggestions: Int {
        self.filter({ $0.isInvalid }).count
    }
}
