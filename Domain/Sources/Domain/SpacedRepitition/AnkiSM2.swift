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
