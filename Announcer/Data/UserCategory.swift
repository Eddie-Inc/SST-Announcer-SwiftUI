//
//  UserCategory.swift
//  Announcer
//
//  Created by Kai Quan Tay on 5/1/23.
//

import Foundation

struct UserCategory: Codable, Equatable, Identifiable {
    var id = UUID()

    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }

    init(_ name: String) {
        self.name = name
    }
}
