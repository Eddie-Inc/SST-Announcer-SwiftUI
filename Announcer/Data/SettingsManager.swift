//
//  SettingsManager.swift
//  Announcer
//
//  Created by Kai Quan Tay on 12/1/23.
//

import Foundation

var defaults = UserDefaults.standard

class SettingsManager {
    static let shared: SettingsManager = .init()
    private init() {
//        let loadNumber = defaults.integer(forKey: "loadNumber")
//        if loadNumber > 0 {
//            self.loadNumber = loadNumber
//        }
    }

    var loadNumber: Int = 10 {
        didSet {
            defaults.set(loadNumber, forKey: "loadNumber")
        }
    }
}
