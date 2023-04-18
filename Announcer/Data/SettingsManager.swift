//
//  SettingsManager.swift
//  Announcer
//
//  Created by Kai Quan Tay on 12/1/23.
//

import Foundation

var defaults = UserDefaults.standard

class SettingsManager: ObservableObject {
    static let shared: SettingsManager = .init()
    private init() {
        if let loadNumber = defaults.object(forKey: "loadNumber") as? Int {
            self.loadNumber = loadNumber
        }

        if let searchLoadNumber = defaults.object(forKey: "searchLoadNumber") as? Int {
            self.searchLoadNumber = searchLoadNumber
        }

        if let searchPostContent = defaults.object(forKey: "searchPostContent") as? Bool {
            self.searchPostContent = searchPostContent
        }

        if let enableReminders = defaults.object(forKey: "enableReminders") as? Bool {
            self.enableReminders = enableReminders
        }
    }

    @Published
    var loadNumber: Int = 10 {
        didSet {
            defaults.set(loadNumber, forKey: "loadNumber")
        }
    }

    @Published
    var searchLoadNumber: Int = 50 {
        didSet {
            defaults.set(searchLoadNumber, forKey: "searchLoadNumber")
        }
    }

    @Published
    var searchPostContent: Bool = false {
        didSet {
            defaults.set(searchPostContent, forKey: "searchPostContent")
        }
    }

    @Published
    var enableReminders: Bool = false {
        didSet {
            defaults.set(enableReminders, forKey: "enableReminders")
        }
    }
}
