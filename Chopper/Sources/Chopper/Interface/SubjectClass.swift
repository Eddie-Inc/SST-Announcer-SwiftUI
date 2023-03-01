//
//  SubjectClass.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 15/2/23.
//

import Foundation
import SwiftUI

// eg. chinese or math. Not any specific timing, just the class itself.
public struct SubjectClass: Identifiable, Equatable, Codable {
    public var name: Name
    public var teacher: String?
    public var color: Color

    public var id = UUID()

    public init(name: Name, teacher: String? = nil, color: Color) {
        self.name = name
        self.teacher = teacher
        self.color = color
    }
}
