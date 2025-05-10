//
//  SuperMemo2.swift
//  Domain
//
//  Created by Kevin Kelly on 5/8/25.
//

/// https://www.supermemo.com/en/blog/application-of-a-computer-to-improve-the-results-obtained-in-working-with-the-supermemo-method

import Foundation

extension SuperMemo2: SpacedRepititionAlgorithm {
    public typealias StepContext = (
        interval: Double?
        , ease_factor: Double?
        , response: SuperMemo2.Response
    )
    public typealias NewContext = (
        interval: Double
        , ease_factor: Double
    )
    
    public static func nextReview(from date: Date, context: StepContext) -> (Date, NewContext) {
        let sm2 = SuperMemo2(
            ease_factor: context.ease_factor
            , interval: context.interval
            , response: context.response
        )
        
        let next_interval = sm2.next_interval()
        let next_date = date.adding(.days(Int(next_interval + 0.99))) ?? date
        
        let next_ease_factor = sm2.next_ease_factor()
        
        return (next_date, (next_interval, next_ease_factor))
    }

}

public final class SuperMemo2 {
    
    public let ease_factor: Double?
    public let last_interval: Double?
    public let response: SuperMemo2.Response
    
    public let ease_factor_floor: Double // standard: 1.3
    public let initial_ease_factor: Double // standard: 2.5
    
    public init(
        ease_factor: Double?
        , interval: Double?
        , response: SuperMemo2.Response
        , ease_factor_floor: Double = 1.3
        , initial_ease_factor: Double = 2.5
    ) {
        self.ease_factor = ease_factor
        self.last_interval = interval
        self.response = response
        self.ease_factor_floor = ease_factor_floor
        self.initial_ease_factor = initial_ease_factor
    }
    
    internal func next_interval() -> Double {
    
        let ease_factor = ease_factor ?? initial_ease_factor
        
        switch last_interval {
        case nil: return 1.0
        case 1.0: return 6.0
        default: return (last_interval ?? 6) * ease_factor
        }

    }
    
    internal func next_ease_factor() -> Double {
        let quality = response.quality
        let ease_factor = ease_factor ?? initial_ease_factor
        
        let next_ease_factor = ease_factor - 0.8 + (0.28 * quality) - (0.02 * quality * quality)
        
        return max(ease_factor_floor, next_ease_factor)
    }
}

extension SuperMemo2 {
    public enum Response: Int, CaseIterable {
        case perfect = 5
        case correct_after_hesitation = 4
        case correct_with_serious_difficulty = 3
        case incorrect_response_easy_to_recall = 2
        case incorrect_response_remembered = 1
        case complete_blackout = 0
        
        var quality: Double { Double(rawValue) }
    }
}
