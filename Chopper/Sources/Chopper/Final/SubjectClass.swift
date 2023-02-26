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

fileprivate extension Color {
    // swiftlint:disable:next large_tuple
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0 // swiftlint:disable:this identifier_name
        var b: CGFloat = 0 // swiftlint:disable:this identifier_name
        var a: CGFloat = 0 // swiftlint:disable:this identifier_name

        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            // Pay attention that the color should be convertible into RGB format
            // Colors using hue, saturation and brightness won't work
            return nil
        }

        return (r, g, b, a)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green) // swiftlint:disable:this identifier_name
        let b = try container.decode(Double.self, forKey: .blue)  // swiftlint:disable:this identifier_name

        self.init(red: r, green: g, blue: b)
    }

    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.colorComponents else {
            return
        }

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
    }
}
