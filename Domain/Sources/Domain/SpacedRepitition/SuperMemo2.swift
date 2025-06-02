//
//  SuperMemo2.swift
//  Domain
//
//  Created by Kevin Kelly on 5/8/25.
//

/// https://www.supermemo.com/en/blog/application-of-a-computer-to-improve-the-results-obtained-in-working-with-the-supermemo-method

import Foundation

public final class SuperMemo2: Codable {
     
    public let ease_factor_floor: Double // standard: 1.3
    public let initial_ease_factor: Double // standard: 2.5
    
    public init(
        ease_factor_floor: Double = 1.3
        , initial_ease_factor: Double = 2.5
    ) {
        self.ease_factor_floor = ease_factor_floor
        self.initial_ease_factor = initial_ease_factor
    }
    
    internal func next_interval(last_interval: Double?, ease_factor: Double?) -> Double {
    
        let ease_factor = ease_factor ?? initial_ease_factor
        
        switch last_interval {
        case nil: return 1.0
        case 1.0: return 6.0
        default: return (last_interval ?? 6) * ease_factor
        }

    }
    
    internal func next_ease_factor(ease_factor: Double?, response: SuperMemo2.Response) -> Double {
        let quality = response.quality
        let ease_factor = ease_factor ?? initial_ease_factor
        
        let next_ease_factor = ease_factor - 0.8 + (0.28 * quality) - (0.02 * quality * quality)
        
        return max(ease_factor_floor, next_ease_factor)
    }
}

extension SuperMemo2 {
    public enum Response: Int, CaseIterable, Codable {
        case perfect = 5
        case correct_after_hesitation = 4
        case correct_with_serious_difficulty = 3
        case incorrect_response_easy_to_recall = 2
        case incorrect_response_remembered = 1
        case complete_blackout = 0
        
        var quality: Double { Double(rawValue) }
    }
}

// MARK: - SRA Conformance

extension SuperMemo2 {
    public struct State: SpacedRepetitionContext {
        /// The amount of time scheduled between the current review and the next review
        public let interval: Double
        /// The ease factor calculated after the current review
        public let ease_factor: Double
        
        public var code: SpacedRepetitionContextCode { .superMemo2_state(self) }
    }
    
    public struct Review: SpacedRepetitionContext {
        /// The date the review took place
        public let date: Date
        /// The quality of the reponse
        public let response: SuperMemo2.Response
        
        public var code: SpacedRepetitionContextCode { .superMemo2_review(self) }
    }
}

extension SuperMemo2: SpacedRepetitionAlgorithm {
    public typealias StateContext = SuperMemo2.State
    
    public typealias ReviewContext = SuperMemo2.Review
    
    public func nextReview(state: StateContext?, review: ReviewContext) -> (nextReview: Date, newState: StateContext) {
        
        let next_interval = self.next_interval(last_interval: state?.interval, ease_factor: state?.ease_factor)
        let next_date = review.date.adding(.days(Int(next_interval))) ?? review.date
        
        let next_ease_factor = self.next_ease_factor(ease_factor: state?.ease_factor, response: review.response)
        
        let new_state = SuperMemo2.State(
            interval: next_interval
            , ease_factor: next_ease_factor
        )
        
        return (next_date, new_state)
    }
    
    public var code: SpacedRepetitionAlgorithmCode { .superMemo2(self) }
}

// MARK: - Conformance

extension SuperMemo2: Equatable {
    public static func == (lhs: SuperMemo2, rhs: SuperMemo2) -> Bool {
        lhs.ease_factor_floor == rhs.ease_factor_floor
        && lhs.initial_ease_factor == rhs.initial_ease_factor
    }
}


