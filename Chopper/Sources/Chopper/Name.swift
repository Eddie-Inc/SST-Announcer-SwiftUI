//
//  Name.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 21/2/23.
//

import Foundation

public enum Name: Equatable, Hashable, Codable {
    case unidentified
    case some(String)

    public var description: String {
        switch self {
        case .unidentified: return "Unidentified"
        case .some(let string): return string
        }
    }

    public var isInvalid: Bool {
        self == .unidentified
    }
}
