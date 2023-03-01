//
//  LoadProgress.swift
//  
//
//  Created by Kai Quan Tay on 1/3/23.
//

import Foundation

/// Represents the load progress of a ``ScheduleSuggestion``
public enum LoadProgress {
    /// Hasn't been loaded yet
    case unloaded
    /// Is being loaded
    case loading
    /// Has been loaded
    case loaded
}
