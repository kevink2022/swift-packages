//
//  Weekday.swift
//  Domain
//
//  Created by Kevin Kelly on 2/23/25.
//

import Foundation

public enum Weekday: String, Codable, CaseIterable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
}

extension Date {
    public static var today: Date {
        Calendar.current.startOfDay(for: .now)
    }
    
    public var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
