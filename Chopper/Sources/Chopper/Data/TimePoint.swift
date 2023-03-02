//
//  TimePoint.swift
//  
//
//  Created by Kai Quan Tay on 2/3/23.
//

import Foundation

public struct TimePoint: AdditiveArithmetic,
                         Comparable,
                         Identifiable,
                         Hashable,
                         Codable,
                         Strideable {
    /// An integer representing the time in military time, eg. 0420 for 4:20AM
    var rawValue: Int

    /// Create a TimePoint based on an integer representing the time in military time, eg. 0420 for 4:20AM
    public init(_ value: Int) {
        self.rawValue = value
    }

    /// Create a TimePoint based on the hour and minute
    public init(hour: Int, minute: Int) {
        assert(0 <= hour && hour < 24)
        assert(0 <= minute && minute < 60)

        self.init(hour*100+minute)
    }

    // MARK: AdditiveArithmetic
    public typealias IntegerLiteralType = Int
    public static var zero: TimePoint { .init(00_00) }
    public static func + (lhs: TimePoint, rhs: TimePoint) -> TimePoint {
        return .init(totalMinutes: lhs.minutes + rhs.minutes)
    }
    public static func - (lhs: TimePoint, rhs: TimePoint) -> TimePoint {
        return .init(totalMinutes: lhs.minutes - rhs.minutes)
    }
    public static func + (lhs: TimePoint, rhs: Int) -> TimePoint {
        return .init(totalMinutes: lhs.totalMinutes + rhs)
    }
    public static func - (lhs: TimePoint, rhs: Int) -> TimePoint {
        return .init(totalMinutes: lhs.totalMinutes + rhs)
    }

    // MARK: Comparable, Identifiable
    public static func < (lhs: TimePoint, rhs: TimePoint) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var id: Int { rawValue }

    // MARK: Codable
    // We use single value encoder for the sake of making the resultant cleaner
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(Int.self))
    }

    // MARK: Strideable
    // TODO: Allow customisation of strideDistance on current schedule
    public static let strideDistance: Int = 20
    public static let startTime: TimePoint = .init(08_00)
    public typealias Stride = Int
    public func distance(to other: TimePoint) -> Int {
        (other.totalMinutes - self.totalMinutes) / 20
    }
    // swiftlint:disable:next identifier_name
    public func advanced(by n: Int) -> TimePoint {
        var mutableSelf = self
        mutableSelf.totalMinutes += n*Self.strideDistance
        return mutableSelf
    }
}

// MARK: Computed values
public extension TimePoint {
    /// The hour of the day
    var hour: Int {
        get {
            rawValue/100
        }
        set {
            rawValue = rawValue%100 + newValue*100
        }
    }

    /// The minute of the hour
    var minutes: Int {
        get {
            rawValue%100
        }
        set {
            rawValue = Int(rawValue/100)*100 + newValue
        }
    }

    /// The time of day in the form of minutes since 00:00
    var totalMinutes: Int {
        get {
            hour*60 + minutes
        }
        set {
            let hours = newValue/60
            let minutes = newValue%60
            self.rawValue = hours*100+minutes
        }
    }

    /// Initialises self from minutes since 00:00
    init(totalMinutes: Int) {
        let hours = totalMinutes/60
        let minutes = totalMinutes%60
        assert(0 <= hours && hours < 24)
        self.init(hour: hours, minute: minutes)
    }

    /// The textual form of the TimePoint's rawValue
    var description: String {
        String(rawValue)
    }
}

/// A typealias for `Range<TimePoint>`
public typealias TimeRange = Range<TimePoint>
