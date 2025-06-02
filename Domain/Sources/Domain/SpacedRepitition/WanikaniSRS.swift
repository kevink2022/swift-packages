//
//  WanikaniSRS.swift
//  Domain
//
//  Created by Kevin Kelly on 5/8/25.
//

/// https://knowledge.wanikani.com/wanikani/srs-stages/

import Foundation

public final class WanikaniSRS {
    internal func nextStage(currentStage: WanikaniSRS.Stage, incorrectAnswers: Int) -> WanikaniSRS.Stage {
        let newStageValue = {
            if incorrectAnswers == 0 { currentStage.rawValue + 1 }
            else { currentStage.rawValue + (incorrectAnswers * currentStage.penaltyFactor) }
        }()
        
        return WanikaniSRS.Stage(rawValue: max(newStageValue, 1)) ?? .apprentice_1
    }
    
    public func nextReview(from date: Date, on stage: WanikaniSRS.Stage, incorrectAnswers: Int) -> (scheduled: Date, newStage: WanikaniSRS.Stage) {
        
        let newStage = nextStage(currentStage: stage, incorrectAnswers: incorrectAnswers)
        let duration = newStage.duration
        let scheduled = date.adding(duration) ?? date
        return (scheduled, newStage)
    }
}

extension WanikaniSRS {
    public enum Stage: Int, CaseIterable, Codable {
        case apprentice_1 = 1
        case apprentice_2 = 2
        case apprentice_3 = 3
        case apprentice_4 = 4
        case guru_1 = 5
        case guru_2 = 6
        case master = 7
        case enlightened = 8
        case burned = 9
        
        var duration: TimeDuration {
            switch self {
            case .apprentice_1: .hours(4)
            case .apprentice_2: .hours(8)
            case .apprentice_3: .days(1)
            case .apprentice_4: .days(2)
            case .guru_1: .weeks(1)
            case .guru_2: .weeks(2)
            case .master: .months(1)
            case .enlightened: .months(4)
            case .burned: .years(1)
            }
        }
        
        var penaltyFactor: Int {
            switch self.rawValue {
            case 1...5: return 2
            default: return 1
            }
        }
    }
}

// MARK: - SRA Conformance

extension WanikaniSRS {
    public struct State: SpacedRepetitionContext {
        public let stage: WanikaniSRS.Stage
        
        public var code: SpacedRepetitionContextCode { .wanikaniSRS_state(self) }
    }
    
    public struct Review: SpacedRepetitionContext {
        public let date: Date
        public let incorrectAnswers: Int
        
        public var code: SpacedRepetitionContextCode { .wanikaniSRS_review(self) }
    }
}

extension WanikaniSRS: SpacedRepetitionAlgorithm {
    public typealias StateContext = WanikaniSRS.State
    public typealias ReviewContext = WanikaniSRS.Review
    
    public func nextReview(state: StateContext?, review: ReviewContext) -> (nextReview: Date, newState: StateContext) {
        
        let currentStage = state?.stage ?? .apprentice_1
        
        let (nextReview, newStage) = nextReview(from: review.date, on: currentStage, incorrectAnswers: review.incorrectAnswers)
        
        return (nextReview, .init(stage: newStage))
    }
    
    public var code: SpacedRepetitionAlgorithmCode { .wanikaniSRS(self) }
}


// MARK: - Conformance

extension WanikaniSRS: Equatable {
    public static func == (lhs: WanikaniSRS, rhs: WanikaniSRS) -> Bool { true }
}
