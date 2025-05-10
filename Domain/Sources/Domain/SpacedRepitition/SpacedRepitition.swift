//
//  SpacedRepitition.swift
//  Domain
//
//  Created by Kevin Kelly on 2/14/25.
//

import Foundation

/// https://github.com/open-spaced-repetition
/// https://expertium.github.io/
/// https://github.com/duolingo/halflife-regression
/// https://nothinghuman.substack.com/p/the-tyranny-of-the-marginal-user
/// https://www.youtube.com/watch?v=Anc2_mnb3V8 how neural networks learn
/// https://faqs.ankiweb.net/what-spaced-repetition-algorithm.html
/// https://www.supermemo.com/en/blog/application-of-a-computer-to-improve-the-results-obtained-in-working-with-the-supermemo-method
/// 


public protocol SpacedRepititionAlgorithm {
    associatedtype StepContext
    associatedtype NewContext
    
    static func nextReview(from: Date, context: StepContext) -> (Date, NewContext)
}


public final class LinearSpacedRepitition: SpacedRepititionAlgorithm {
    public typealias StepContext = TimeDuration
    public typealias NewContext = TimeDuration
    
    public static func nextReview(from date: Date, context duration: TimeDuration) -> (Date, TimeDuration) {
        let nextDate = date.adding(duration) ?? date
        return (nextDate, duration)
    }
}

public final class AnkiSRS {
    public enum Grade: Int, CaseIterable {
        case forgot = 1
        case hard = 2
        case good = 3
        case easy = 4
        
        public var value: Double { Double(self.rawValue) }
        public var isSuccess: Bool { self != .forgot }
    }
}
