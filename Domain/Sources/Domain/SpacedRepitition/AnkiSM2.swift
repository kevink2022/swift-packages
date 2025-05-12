//
//  AnkiSM2.swift
//  Domain
//
//  Created by Kevin Kelly on 5/8/25.
//

/// https://faqs.ankiweb.net/what-spaced-repetition-algorithm.html

import Foundation

public final class AnkiSM2 {
    
    public init(
        first_interval: Double
        , second_interval: Double
    ) {
        self.first_interval = first_interval
        self.second_interval = second_interval
    }
    
    let first_interval: Double
    let second_interval: Double
}


public final class AnkiSRS: Codable {
    public enum Grade: Int, CaseIterable, Codable {
        case forgot = 1
        case hard = 2
        case good = 3
        case easy = 4
        
        public var value: Double { Double(self.rawValue) }
        public var isSuccess: Bool { self != .forgot }
    }
}
