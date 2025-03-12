//
//  Weekday.swift
//  Domain
//
//  Created by Kevin Kelly on 2/23/25.
//

import Foundation
import SwiftUI

public enum Weekday: Int, CaseIterable, Codable, Identifiable, Equatable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    public var id: Int { self.rawValue }
    
    // Get the current weekday
    public static var today: Weekday {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        return Weekday(rawValue: weekday) ?? .monday
    }
    
    public var name: String {
        DateFormatter().weekdaySymbols[self.rawValue - 1]
    }
    
    public var shortName: String {
        DateFormatter().shortWeekdaySymbols[self.rawValue - 1]
    }
    
    public var veryShortName: String {
        DateFormatter().veryShortWeekdaySymbols[self.rawValue - 1]
    }
}

extension Date {
    public static var today: Date {
        Calendar.current.startOfDay(for: .now)
    }
    
    public var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
