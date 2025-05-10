//
//  LeitnerBox.swift
//  Domain
//
//  Created by Kevin Kelly on 5/8/25.
//

import Foundation

extension LeitnerBox: SpacedRepititionAlgorithm {
    public typealias StepContext = (level: Int?, correct: Bool)
    public typealias NewContext = Int
    
    public static func nextReview(from date: Date, context: StepContext) -> (Date, NewContext) {
        LeitnerBox.nextReview(from: date, correct: context.correct, on: context.level)
    }
}

public final class LeitnerBox {
    
    static func nextReview(from date: Date, correct: Bool, on level: Int? = nil) -> (nextReview: Date, newLevel: Int) {
        
        let newLevel = {
            if correct { (level ?? 1) + 1 }
            else { 1 }
        }()
        
        let newInterval = [1...newLevel].reduce(1) { partialResult, _ in partialResult*2 } / 2
        
        let nextReview = date.adding(.days(newInterval)) ?? date
        
        return (nextReview, newInterval)
    }
}
