//
//  Color+Components+Codable.swift
//  
//
//  Created by Kai Quan Tay on 1/3/23.
//

import SwiftUI

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
        do {
            let r = try container.decode(Int.self, forKey: .red)
            let g = try container.decode(Int.self, forKey: .green) // swiftlint:disable:this identifier_name
            let b = try container.decode(Int.self, forKey: .blue)  // swiftlint:disable:this identifier_name
            self.init(red: Double(r)/255,
                      green: Double(g)/255,
                      blue: Double(b)/255)
        } catch {
            // legacy system
            let r = try container.decode(Double.self, forKey: .red)
            let g = try container.decode(Double.self, forKey: .green)
            let b = try container.decode(Double.self, forKey: .blue)
            self.init(red: r, green: g, blue: b)
        }
    }

    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.colorComponents else {
            return
        }

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(Int(colorComponents.red * 255), forKey: .red)
        try container.encode(Int(colorComponents.green * 255), forKey: .green)
        try container.encode(Int(colorComponents.blue * 255), forKey: .blue)
    }
}
