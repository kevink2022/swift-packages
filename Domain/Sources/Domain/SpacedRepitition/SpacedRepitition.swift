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

public protocol SpacedRepititionAlgorithm: Codable {
    /// Data from the last review, such as the level/stage.
    associatedtype StateContext: Codable
    /// Data from the review itself, such as the grade and date of review.
    associatedtype ReviewContext: Codable
    
    /// Calculates the next review based on the state context and the review context, returning the date to schedule the next review, as well as the new state. State is `nil` on the initial review.
    func nextReview(state: StateContext?, review: ReviewContext) -> (nextReview: Date, newState: StateContext)
    
    /// The code defining which context and algorithm this structure is a part of.
    var code: SpacedRepititionType { get }
    
    /*
    /// Data to configure the spaced repitition algorithm
    associatedtype ConfigurationContext: Codable
    
    init(configuration: ConfigurationContext)
    
    /// The standard, default configuration for the algorithm.
    var standardConfig: ConfigurationContext { get }
    */
}

public enum SpacedRepititionType: Codable {
    case linear(LinearSpacedRepitition)
    case leitnerBox(LeitnerBox)
    case superMemo2(SuperMemo2)
    case ankiFSRS_5(AnkiFSRS_5)
    case wanikaniSRS(WanikaniSRS)
}

public enum SpacedRepititionContext: Codable {
    case algorithm(SpacedRepititionType)
    case config(SpacedRepititionType)
    case state(SpacedRepititionType)
//    case review(SpacedRepititionType)
}

public protocol SpacedRepititionCodable: Codable {
    var contextCode: SpacedRepititionContext { get }
}
