//
//  RGBA32.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 14/2/23.
//

import SwiftUI

/// Represents a single RGBA pixel.
struct RGBA32: Equatable {
    private var color: UInt32

    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }

    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }

    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }

    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let red   = UInt32(red)
        let green = UInt32(green)
        let blue  = UInt32(blue)
        let alpha = UInt32(alpha)
        color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
    }

    // swiftlint:disable:next swiftlint_file_disabling
    // swiftlint:disable comma comma_space_rule
    static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
    static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
    static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
    static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
    static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
    static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
    static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
    static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)
    // swiftlint:enable comma comma_space_rule

    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

    static func == (lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }

    /// If the pixel is roughly black
    var isBlackish: Bool {
        self.blueComponent < tolerance &&
        self.redComponent < tolerance &&
        self.greenComponent < tolerance
    }

    /// If the pixel is roughly white
    var isWhitish: Bool {
        self.blueComponent > 255-tolerance &&
        self.redComponent > 255-tolerance &&
        self.greenComponent > 255-tolerance
    }

    /// If the pixel roughly matches a certain color
    func roughlyMatches(color: RGBA32) -> Bool {
        Int(self.blueComponent) > Int(color.blueComponent)-tolerance &&
        Int(self.redComponent) > Int(color.redComponent)-tolerance &&
        Int(self.greenComponent) > Int(color.greenComponent)-tolerance &&

        Int(self.blueComponent) < Int(color.blueComponent)+tolerance &&
        Int(self.redComponent) < Int(color.redComponent)+tolerance &&
        Int(self.greenComponent) < Int(color.greenComponent)+tolerance
    }
}

private var tolerance: Int = 5
