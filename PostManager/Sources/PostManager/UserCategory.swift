//
//  UserCategory.swift
//  Announcer
//
//  Created by Kai Quan Tay on 5/1/23.
//

import Foundation

public struct UserCategory: Codable, Equatable, Identifiable, Hashable {
    public var id = UUID()

    public var name: String

    public init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }

    public init(_ name: String) {
        self.name = name
    }
}
