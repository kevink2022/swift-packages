//
//  AnkiFSRS.swift
//  Domain
//
//  Created by Kevin Kelly on 4/7/25.
//

import Foundation

public final class AnkiFSRS_5 {
    
    // MARK: - Parameters
    public let desiredRetention: Double
    public var parameters: AnkiFSRS_5.Parameters { storedParameters ?? .standard }
    
    internal let storedParameters: AnkiFSRS_5.Parameters?
    internal let curveMod_f: Double = 19/81
    internal let curveMod_c: Double = -0.5
    
    public init(
        desiredRetention: Double = 0.9
        , parameters: AnkiFSRS_5.Parameters? = nil
    ) {
        self.desiredRetention = desiredRetention
        self.storedParameters = parameters
    }
    /*
    public func nextReview(daysSinceLastReview: Double, grade: AnkiFSRS_5.Grade, state: AnkiFSRS_5.State?) -> (nextReview: Double, newState: AnkiFSRS_5.State) {
        guard let state = state else {
            
            
            let initialState = AnkiFSRS_5.State(
                difficulty: initialDifficulty(grade: grade),
                stability: initialStability(grade: grade),
                retrievability: retrievability(daysSinceLastReview: <#T##Double#>, state: <#T##State#>)
            )
            
        }
        let newState = AnkiFSRS_5.State(
            difficulty: <#T##Double#>
            , stability: <#T##Double#>
            , retrievability: <#T##Double#>
        )
    }
    */
    internal func retrievability(daysSinceLastReview: Double, state: AnkiFSRS_5.State) -> Double {
        pow((1.0 + curveMod_f * (daysSinceLastReview / state.stability)), curveMod_c)
    }
    
    internal func reviewInterval(state: AnkiFSRS_5.State) -> Double {
        (state.stability / curveMod_f) * (pow(desiredRetention, 1/curveMod_c) - 1)
    }
    
    internal func initialStability(grade: AnkiFSRS_5.Grade) -> Double {
        let params = parameters.initial.stability
        
        return switch grade {
        case .forgot: params.forgot
        case .hard: params.hard
        case .good: params.good
        case .easy: params.easy
        }
    }
    
    internal func nextStability(grade: AnkiFSRS_5.Grade, state: AnkiFSRS_5.State) -> Double {
        let nextStability = grade.isSuccess ? nextStabilityOnSuccess : nextStabilityOnFailure
        return nextStability(grade, state)
    }
    
    internal func nextStabilityOnSuccess(grade: AnkiFSRS_5.Grade, state: AnkiFSRS_5.State) -> Double {
        let successParams = parameters.stability.success
        let multiplierParams = parameters.stability.multiplier
        
        let difficultyPenalty = 11 - state.difficulty
        let stabilityModifier = pow(state.stability, -successParams.stabilityModifier)
        let retrievabilitySaturation = pow(M_E, successParams.retrievabilitySaturation * (1 - state.retrievability)) - 1
        let hardPenalty = grade == .hard ? multiplierParams.hard : 1
        let easyBonus = grade == .easy ? multiplierParams.easy : 1
        
        return (1 + (
            difficultyPenalty *
            stabilityModifier *
            retrievabilitySaturation *
            hardPenalty *
            easyBonus *
            pow(M_E, successParams.exponent)
        ))
    }
    
    internal func nextStabilityOnFailure(grade: AnkiFSRS_5.Grade, state: AnkiFSRS_5.State) -> Double {
        let failParams = parameters.stability.fail
        
        let difficultyModifier = pow(state.difficulty, -failParams.difficultyModifier)
        let stabilityModifier = pow((state.stability + 1), failParams.stabilityModifier) - 1
        let retrievabilityModifier = pow(M_E, failParams.retrievabilityModifier * (1 - state.retrievability))
                
        return difficultyModifier * stabilityModifier * retrievabilityModifier * failParams.multiplier
    }
    
    internal func initialDifficulty(grade: AnkiFSRS_5.Grade) -> Double {
        let params = parameters.initial.difficulty
        
        let difficulty = params.good - pow(M_E, params.multiplier * (grade.value)) + 1
        
        return clampDifficulty(difficulty)
    }
    
    internal func clampDifficulty(_ difficulty: Double) -> Double {
        let flooredDifficulty = max(difficulty, 1)
        let cappedDifficulty = min(flooredDifficulty, 10)
        
        return cappedDifficulty
    }
    
    internal func nextDifficulty(grade: AnkiFSRS_5.Grade, state: AnkiFSRS_5.State) -> Double {
        let multiplier = parameters.difficulty.multiplier
        return multiplier * initialDifficulty(grade: .good) + (1 - multiplier) * difficultySlope(grade: grade, state: state)
    }
    
    internal func difficultySlope(grade: AnkiFSRS_5.Grade, state: AnkiFSRS_5.State) -> Double {
        state.difficulty + difficultyDelta(grade: grade) * ((10 - state.difficulty) - 9)
    }
    
    internal func difficultyDelta(grade: AnkiFSRS_5.Grade) -> Double {
        return -parameters.difficulty.deltaMultiplier * (grade.value - 3)
    }
}

// MARK: - State
extension AnkiFSRS_5 {
    public struct State {
        public let difficulty: Double
        public let stability: Double
        public let retrievability: Double
        
        public init(
            difficulty: Double
            , stability: Double
            , retrievability: Double
        ) {
            self.difficulty = difficulty
            self.stability = stability
            self.retrievability = retrievability
        }
    }
}

// MARK: - Grade
extension AnkiFSRS_5 {
    public enum Grade: Int, CaseIterable {
        case forgot = 1
        case hard = 2
        case good = 3
        case easy = 4
        
        public var value: Double { Double(self.rawValue) }
        public var isSuccess: Bool { self != .forgot }
    }
}

// MARK: - Parameters
extension AnkiFSRS_5 {
    public struct Parameters {
        public let initial: Initial
        public let difficulty: Difficulty
        public let stability: Stability
        
        public static let standard = Parameters(
            initial: .standard,
            difficulty: .standard,
            stability: .standard
        )
        
        public static let standardValues: [Double] = [
            // Initial.Stability (w0-w3)
            0.40255, 1.18385, 3.173, 15.69105,
            // Initial.Difficulty (w4-w5)
            7.1949, 0.5345,
            // Difficulty (w6-w7)
            1.4604, 0.0046,
            // Stability.Success (w8-w10)
            1.54575, 0.1192, 1.01925,
            // Stability.Fail (w11-w14)
            1.9395, 0.11, 0.29605, 2.2698,
            // Stability.Multiplier (w15-w16)
            0.2315, 2.9898,
            // Stability.ShortTerm (w17-w18)
            0.51655, 0.6621
        ]
        
        public init(initial: Initial, difficulty: Difficulty, stability: Stability) {
            self.initial = initial
            self.difficulty = difficulty
            self.stability = stability
        }
        
        public init(parameters: [Double]) {
            guard parameters.count == 19 else {
                self = .standard
                return
            }
            
            self.initial = Initial(parameters: Array(parameters[0...5]))
            self.difficulty = Difficulty(parameters: Array(parameters[6...7]))
            self.stability = Stability(parameters: Array(parameters[8...18]))
        }
        
        public struct Initial {
            public let stability: Stability
            public let difficulty: Difficulty
            
            public static let standard = Initial(
                stability: .standard,
                difficulty: .standard
            )
            
            public static let standardValues = Array(Parameters.standardValues[0...5])
            
            public init(stability: Stability, difficulty: Difficulty) {
                self.stability = stability
                self.difficulty = difficulty
            }
            
            public init(parameters: [Double]) {
                guard parameters.count == 6 else {
                    self = .standard
                    return
                }
                
                self.stability = Stability(parameters: Array(parameters[0...3]))
                self.difficulty = Difficulty(parameters: Array(parameters[4...5]))
            }
            
            public struct Stability {
                public let forgot: Double // w0
                public let hard: Double // w1
                public let good: Double // w2
                public let easy: Double // w3
                
                public static let standard = Stability(
                    forgot: Parameters.standardValues[0],
                    hard: Parameters.standardValues[1],
                    good: Parameters.standardValues[2],
                    easy: Parameters.standardValues[3]
                )
                
                public static let standardValues = Array(Parameters.standardValues[0...3])
                
                public init(forgot: Double, hard: Double, good: Double, easy: Double) {
                    self.forgot = forgot
                    self.hard = hard
                    self.good = good
                    self.easy = easy
                }
                
                public init(parameters: [Double]) {
                    guard parameters.count == 4 else { self = .standard; return }
                    
                    self.forgot = parameters[0]
                    self.hard = parameters[1]
                    self.good = parameters[2]
                    self.easy = parameters[3]
                }
            }
            
            public struct Difficulty {
                public let good: Double // w4
                public let multiplier: Double // w5
                
                public static let standard = Difficulty(
                    good: Parameters.standardValues[4],
                    multiplier: Parameters.standardValues[5]
                )
                
                public static let standardValues = Array(Parameters.standardValues[4...5])
                
                public init(good: Double, multiplier: Double) {
                    self.good = good
                    self.multiplier = multiplier
                }
                
                public init(parameters: [Double]) {
                    guard parameters.count == 2 else { self = .standard; return }
                    
                    self.good = parameters[0]
                    self.multiplier = parameters[1]
                }
            }
        }
        
        public struct Difficulty {
            public let deltaMultiplier: Double // w6
            public let multiplier: Double // w7
            
            public static let standard = Difficulty(
                deltaMultiplier: Parameters.standardValues[6],
                multiplier: Parameters.standardValues[7]
            )
            
            public static let standardValues = Array(Parameters.standardValues[6...7])
            
            public init(deltaMultiplier: Double, multiplier: Double) {
                self.deltaMultiplier = deltaMultiplier
                self.multiplier = multiplier
            }
            
            public init(parameters: [Double]) {
                guard parameters.count == 2 else {
                    self = .standard
                    return
                }
                
                self.deltaMultiplier = parameters[0]
                self.multiplier = parameters[1]
            }
        }
        
        public struct Stability {
            public let success: Success
            public let fail: Fail
            public let multiplier: Multiplier
            public let shortTerm: ShortTerm
            
            public static let standard = Stability(
                success: .standard,
                fail: .standard,
                multiplier: .standard,
                shortTerm: .standard
            )
            
            public static let standardValues = Array(Parameters.standardValues[8...18])
            
            public init(success: Success, fail: Fail, multiplier: Multiplier, shortTerm: ShortTerm) {
                self.success = success
                self.fail = fail
                self.multiplier = multiplier
                self.shortTerm = shortTerm
            }
            
            public init(parameters: [Double]) {
                guard parameters.count == 11 else {
                    self = .standard
                    return
                }
                
                self.success = Success(parameters: Array(parameters[0...2]))
                self.fail = Fail(parameters: Array(parameters[3...6]))
                self.multiplier = Multiplier(parameters: Array(parameters[7...8]))
                self.shortTerm = ShortTerm(parameters: Array(parameters[9...10]))
            }
            
            public struct Success {
                public let exponent: Double // w8
                public let stabilityModifier: Double // w9
                public let retrievabilitySaturation: Double // w10
                
                public static let standard = Success(
                    exponent: Parameters.standardValues[8],
                    stabilityModifier: Parameters.standardValues[9],
                    retrievabilitySaturation: Parameters.standardValues[10]
                )
                
                public static let standardValues = Array(Parameters.standardValues[8...10])
                
                public init(exponent: Double, stabilityModifier: Double, retrievabilitySaturation: Double) {
                    self.exponent = exponent
                    self.stabilityModifier = stabilityModifier
                    self.retrievabilitySaturation = retrievabilitySaturation
                }
                
                public init(parameters: [Double]) {
                    guard parameters.count == 3 else { self = .standard; return }
                    
                    self.exponent = parameters[0]
                    self.stabilityModifier = parameters[1]
                    self.retrievabilitySaturation = parameters[2]
                }
            }
            
            public struct Fail {
                public let multiplier: Double // w11
                public let difficultyModifier: Double // w12
                public let stabilityModifier: Double // w13
                public let retrievabilityModifier: Double // w14
                
                public static let standard = Fail(
                    multiplier: Parameters.standardValues[11],
                    difficultyModifier: Parameters.standardValues[12],
                    stabilityModifier: Parameters.standardValues[13],
                    retrievabilityModifier: Parameters.standardValues[14]
                )
                
                public static let standardValues = Array(Parameters.standardValues[11...14])
                
                public init(
                    multiplier: Double
                    , difficultyModifier: Double
                    , stabilityModifier: Double
                    , retrievabilityModifier: Double
                ) {
                    self.multiplier = multiplier
                    self.difficultyModifier = difficultyModifier
                    self.stabilityModifier = stabilityModifier
                    self.retrievabilityModifier = retrievabilityModifier
                }
                
                public init(parameters: [Double]) {
                    guard parameters.count == 4 else { self = .standard; return }
                                        
                    self.multiplier = parameters[0]
                    self.difficultyModifier = parameters[1]
                    self.stabilityModifier = parameters[2]
                    self.retrievabilityModifier = parameters[3]
                }
            }
            
            public struct Multiplier {
                public let hard: Double // w15
                public let easy: Double // w16
                
                public static let standard = Multiplier(
                    hard: Parameters.standardValues[15],
                    easy: Parameters.standardValues[16]
                )
                
                public static let standardValues = Array(Parameters.standardValues[15...16])
                
                public init(hard: Double, easy: Double) {
                    self.hard = hard
                    self.easy = easy
                }
                
                public init(parameters: [Double]) {
                    guard parameters.count == 2 else { self = .standard; return }
                    
                    self.hard = parameters[0]
                    self.easy = parameters[1]
                }
            }
            
            public struct ShortTerm {
                public let exponent: Double // w17
                public let exponent2: Double // w18
                 
                public static let standard = ShortTerm(
                    exponent: Parameters.standardValues[17],
                    exponent2: Parameters.standardValues[18]
                )
                
                public static let standardValues = Array(Parameters.standardValues[17...18])
                
                public init(exponent: Double, exponent2: Double) {
                    self.exponent = exponent
                    self.exponent2 = exponent2
                }
                
                public init(parameters: [Double]) {
                    guard parameters.count == 2 else { self = .standard; return }
                    
                    self.exponent = parameters[0]
                    self.exponent2 = parameters[1]
                }
            }
        }
    }
}


