//
//  Linear.swift
//  Domain
//
//  Created by Kevin Kelly on 5/10/25.
//

import Foundation


public final class LinearSpacedRepetition {
    public let spacing: TimeDuration
    
    public init(spacing: TimeDuration) {
        self.spacing = spacing
    }
    
    public func nextReview(from date: Date) -> Date { return date.adding(spacing) ?? date }
}

// MARK: - SRA Conformance

extension LinearSpacedRepetition {
    public struct State: SpacedRepetitionContext {
        public static func == (lhs: LinearSpacedRepetition.State, rhs: LinearSpacedRepetition.State) -> Bool { true }
        
        public init() { self.empty = Empty() }
        
        public var empty: Empty
        
        public var code: SpacedRepetitionContextCode { .linear_state(self) }
    }
    
    public struct Review: SpacedRepetitionContext {
        public init(date: Date) { self.date = date }
        
        /// The date of the review
        public let date: Date
        
        public var code: SpacedRepetitionContextCode { .linear_review(self) }
    }
}

extension LinearSpacedRepetition: SpacedRepetitionAlgorithm {
    public typealias StateContext = LinearSpacedRepetition.State
    public typealias ReviewContext = LinearSpacedRepetition.Review
    
    public func nextReview(state: StateContext?, review: ReviewContext) -> (nextReview: Date, newState: StateContext) {
        return (nextReview(from: review.date), LinearSpacedRepetition.State())
    }

    public var code: SpacedRepetitionAlgorithmCode { .linear(self) }
}

// MARK: - Conformance

extension LinearSpacedRepetition: Equatable {
    public static func == (lhs: LinearSpacedRepetition, rhs: LinearSpacedRepetition) -> Bool {
        lhs.spacing == rhs.spacing
    }
}


