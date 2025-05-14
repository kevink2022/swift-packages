//
//  LeitnerBox.swift
//  Domain
//
//  Created by Kevin Kelly on 5/8/25.
//

import Foundation

public final class LeitnerBox: Codable {
    
    static func nextReview(from date: Date, correct: Bool, level: Int? = nil) -> (nextReview: Date, newLevel: Int) {
        
        let newLevel = {
            if correct { (level ?? 1) + 1 }
            else { 1 }
        }()
        
        let newInterval = [1...newLevel].reduce(1) { partialResult, _ in partialResult*2 } / 2
        
        let nextReview = date.adding(.days(newInterval)) ?? date
        
        return (nextReview, newInterval)
    }
}

extension LeitnerBox {
    public struct State: SpacedRepetitionContext {
        /// Boolean representing whether the card was correctly answered
        public let level: Int
        
        public var code: SpacedRepetitionContextCode { .leitnerBox_state(self) }
    }
    
    public struct Review: SpacedRepetitionContext {
        /// Boolean representing whether the card was correctly answered
        public let correct: Bool
        /// The date of the review
        public let date: Date
        
        public var code: SpacedRepetitionContextCode { .leitnerBox_review(self) }
    }
}

extension LeitnerBox: SpacedRepetitionAlgorithm {
    public typealias StateContext = LeitnerBox.State
    public typealias ReviewContext = LeitnerBox.Review
    
    public func nextReview(state: StateContext?, review: ReviewContext) -> (nextReview: Date, newState: StateContext) {
        let (nextReview, newLevel) = LeitnerBox.nextReview(from: review.date, correct: review.correct, level: state?.level)
        
        return (nextReview, LeitnerBox.State(level: newLevel))
    }
    
    public var code: SpacedRepetitionAlgorithmCode { .leitnerBox(self) }
}
