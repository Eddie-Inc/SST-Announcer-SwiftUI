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

    enum Keys: CodingKey {
        case name, teacher, color
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)

        switch name {
        case .some(let string):
            try container.encode(string, forKey: .name)
        default: break
        }

        if let teacher {
            try container.encode(teacher, forKey: .teacher)
        }

        try container.encode(color, forKey: .color)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let rawName = try? container.decode(String.self, forKey: .name)
        if let rawName {
            self.name = .some(rawName)
        } else {
            self.name = .unidentified
        }

        let teacher = try? container.decode(String.self, forKey: .teacher)
        if let teacher {
            self.teacher = .some(teacher)
        }

        self.color = try container.decode(Color.self, forKey: .color)

        self.id = .init()
    }
}
