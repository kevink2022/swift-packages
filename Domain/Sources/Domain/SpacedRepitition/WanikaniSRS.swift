//
//  WanikaniSRS.swift
//  Domain
//
//  Created by Kevin Kelly on 5/8/25.
//

/// https://knowledge.wanikani.com/wanikani/srs-stages/

import Foundation

extension WanikaniSRS: SpacedRepititionAlgorithm {
    public typealias StepContext = (stage: WanikaniSRS.Stage, incorrectAnswers: Int)
    public typealias NewContext = WanikaniSRS.Stage
    
    public static func nextReview(from date: Date, context: StepContext) -> (Date, NewContext) {
        WanikaniSRS().nextReview(from: date, on: context.stage, incorrectAnswers: context.incorrectAnswers)
    }
}


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
    public enum Stage: Int, CaseIterable {
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
