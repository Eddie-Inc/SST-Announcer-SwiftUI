//
//  SubjectClass.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 15/2/23.
//

import Foundation
import SwiftUI

/// A struct that represents a class, such as English or Geography.
public struct SubjectClass: Identifiable, Equatable, Codable {
    /// The name of the class
    public var name: Name
    /// The teacher of the class, if one exists
    public var teacher: String?
    /// The color to show for the class
    public var color: Color

    public var id = UUID()

    public init(name: Name, teacher: String? = nil, color: Color) {
        self.name = name
        self.teacher = teacher
        self.color = color
    }
}
