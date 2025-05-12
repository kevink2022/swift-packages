//
//  Linear.swift
//  Domain
//
//  Created by Kevin Kelly on 5/10/25.
//

import Foundation


public final class LinearSpacedRepetition {
    public let spacing: TimeDuration
    
    public func nextReview(from date: Date) -> Date { return date.adding(spacing) ?? date }
}

extension LinearSpacedRepetition: SpacedRepetitionAlgorithm {
    public typealias StateContext = Empty
    public typealias ReviewContext = Date
    
    public func nextReview(state: StateContext?, review: Date) -> (nextReview: Date, newState: StateContext) {
        return (nextReview(from: review), Empty())
    }
    
    public var code: SpacedRepetitionType { .linear(self) }
}

