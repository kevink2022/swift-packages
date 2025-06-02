//
//  AnkiFSRS.swift
//  Domain
//
//  Created by Kevin Kelly on 4/7/25.
//

/// https://faqs.ankiweb.net/what-spaced-repetition-algorithm.html
/// https://borretti.me/article/implementing-fsrs-in-100-lines
/// https://open-spaced-repetition.github.io/anki_fsrs_visualizer/

import Foundation

public final class AnkiFSRS: Codable {
    
    // MARK: - Parameters
    public var desiredRetention: Double { storedDesiredRetention ?? Self.standardDesiredRetention }
    public var parameters: AnkiFSRS.Parameters { storedParameters ?? .standard }
    private var w: AnkiFSRS.Parameters { parameters }
    
    public let storedDesiredRetention: Double?
    internal static let standardDesiredRetention = 0.9
    
    internal let storedParameters: AnkiFSRS.Parameters?
    
    internal var factor: Double { pow(0.9, -(1.0 / w[20])) - 1 }
    internal var decay: Double { -w[20] }
    
    public init(
        desiredRetention: Double = 0.9
        , parameters: AnkiFSRS.Parameters? = nil
    ) {
        self.storedDesiredRetention = desiredRetention
        self.storedParameters = parameters
    }
}

// MARK: - Methods

extension AnkiFSRS {
    public func nextReview(from date: Date, state: AnkiFSRS.State?, grade: AnkiSRS.Grade) -> (nextReview: Date, newState: AnkiFSRS.State) {
                        
        let newState = {
            if let beforeState = state {
                let interval = date.daysSince(beforeState.lastReviewed)
                
                return AnkiFSRS.State(
                    difficulty: difficultyAfterReview(state: beforeState, grade: grade)
                    , stability: stabilityAfterReview(interval: interval, state: beforeState, grade: grade)
                    , lastReviewed: date
                )
            } else {
                return AnkiFSRS.State(
                    difficulty: initialDifficulty(grade: grade),
                    stability: initialStability(grade: grade),
                    lastReviewed: date
                )
            }
        }()
        
        let nextReviewInterval = nextInterval(state: newState)
        let nextReview = date.addingDays(nextReviewInterval)
        
        return (nextReview, newState)
    }
    
    internal func initialStability(grade: AnkiSRS.Grade) -> Double {
        return switch grade {
        case .forgot: w[0]
        case .hard: w[1]
        case .good: w[2]
        case .easy: w[3]
        }
    }
    
    internal func clampDifficulty(_ difficulty: Double) -> Double {
        let floor = 1.0
        let ceiling = 10.0
        
        return min(max(difficulty, floor), ceiling)
    }
    
    internal func initialDifficulty(grade: AnkiSRS.Grade) -> Double {
        let difficulty = w[4] - pow(M_E, w[5] * (grade.value - 1)) + 1
        
        return clampDifficulty(difficulty)
    }
    
    internal func nextInterval(state: AnkiFSRS.State) -> Double {
        (state.stability / factor) * (pow(desiredRetention, 1/decay) - 1)
    }
    
    internal func retrievability(state: AnkiFSRS.State, interval: Double) -> Double {
        pow((1.0 + factor * (interval / state.stability)), decay)
    }
    
    internal func difficultyDelta(grade: AnkiSRS.Grade) -> Double {
        return -w[6] * (grade.value - 3)
    }
    
    internal func difficultyPrime(state: AnkiFSRS.State, grade: AnkiSRS.Grade) -> Double {
        state.difficulty + difficultyDelta(grade: grade) * ((10 - state.difficulty) / 9)
    }
    
    internal func difficultyAfterReview(state: AnkiFSRS.State, grade: AnkiSRS.Grade) -> Double {
        w[7] * initialDifficulty(grade: .easy) + (1 - w[7]) * difficultyPrime(state: state, grade: grade)
    }
        
    internal func stabilityAfterRemembered(interval: Double, state: AnkiFSRS.State, grade: AnkiSRS.Grade) -> Double {
        let retrievability = retrievability(state: state, interval: interval)
        let exp_1 = pow(M_E, w[8])
        let exp_2 = (11 - state.difficulty)
        let exp_3 = pow(state.stability, -w[9])
        let exp_4 = pow(M_E, w[10] * (1-retrievability)) - 1
        let exp_5 = grade == .hard ? w[15] : 1
        let exp_6 = grade == .easy ? w[16] : 1
        
        return state.stability * ( exp_1 * exp_2 * exp_3 * exp_4 * exp_5 * exp_6 + 1 )
    }
    
    internal func stabilityAfterForgot(interval: Double, state: AnkiFSRS.State) -> Double {
        let retrievability = retrievability(state: state, interval: interval)
        let exp_1 = w[11]
        let exp_2 = pow(state.difficulty, -w[12])
        let exp_3 = pow(state.stability + 1, w[13]) - 1
        let exp_4 = pow(M_E, w[14] * (1-retrievability))
        
        return ( exp_1 * exp_2 * exp_3 * exp_4 )
    }
    
    internal func stabilityShortTerm(state: AnkiFSRS.State, grade: AnkiSRS.Grade) -> Double {
        let exp_1 = w[17] * ( grade.value-3+w[18] )
        
        return state.stability * pow(M_E, exp_1) * pow(state.stability, -w[19])
    }
    
    internal func stabilityAfterReview(interval: Double, state: AnkiFSRS.State, grade: AnkiSRS.Grade) -> Double {
        guard interval >= 1 else { return stabilityShortTerm(state: state, grade: grade) }
        
        switch grade {
        case .forgot: return stabilityAfterForgot(interval: interval, state: state)
        default: return stabilityAfterRemembered(interval: interval, state: state, grade: grade)
        }
    }
}

// MARK: - SRA Conformance

extension AnkiFSRS {
    public struct State: SpacedRepetitionContext {
        public let difficulty: Double
        public let stability: Double
        public let lastReviewed: Date
        
        public init(
            difficulty: Double
            , stability: Double
            , lastReviewed: Date
        ) {
            self.difficulty = difficulty
            self.stability = stability
            self.lastReviewed = lastReviewed
        }
        
        /*
        internal func retrievability(from date: Date) -> Double {
            let lastReviewInterval = date.timeIntervalSince(self.lastReviewed) / 86400
            return retrievability(interval: lastReviewInterval, state: self)
        }
        
        internal func retrievability(interval: Double, state: AnkiFSRS.State) -> Double {
            pow((1.0 + AnkiFSRS.curveMod_f * (interval / state.stability)), AnkiFSRS.curveMod_c)
        }
         */
        
        public var code: SpacedRepetitionContextCode { .ankiFSRS_state(self) }
    }
    
    public struct Review: SpacedRepetitionContext {
        public let grade: AnkiSRS.Grade
        public let date: Date
        
        public var code: SpacedRepetitionContextCode { .ankiFSRS_review(self) }
    }
}

extension AnkiFSRS: SpacedRepetitionAlgorithm {
    public typealias StateContext = AnkiFSRS.State
    public typealias ReviewContext = AnkiFSRS.Review
    
    public func nextReview(state: StateContext?, review: ReviewContext) -> (nextReview: Date, newState: StateContext) {
        nextReview(from: review.date, state: state, grade: review.grade)
    }
    
    public var code: SpacedRepetitionAlgorithmCode { .ankiFSRS_5(self) }
}

extension AnkiFSRS {
    public struct Parameters: Codable, Equatable {
        /*
        public let initial: Initial
        public let difficulty: Difficulty
        public let stability: Stability
        */
         
        internal let storage: [Double]
        
        public static let standard = Parameters(
            parameters: Self.standardValues
        )
            
        public static let standardValues: [Double] = [
            // Initial.Stability (w0-w3)
            0.2172, 1.1771, 3.2602, 16.1507,
            // Initial.Difficulty (w4-w5)
            7.0114, 0.57,
            // Difficulty (w6-w7)
            2.0966, 0.0069,
            // Stability.Success (w8-w10)
            1.5261, 0.112, 1.0178,
            // Stability.Fail (w11-w14)
            1.849, 0.1133, 0.3127, 2.2934,
            // Stability.Multiplier (w15-w16)
            0.2191, 3.0004,
            // Stability.ShortTerm (w17-w19)
            0.7536, 0.3332, 0.1437,
            // Decay (w20)
            0.2
        ]
        
        public static let parameterCount: Int = standardValues.count
        
        public subscript(index: Int) -> Double {
            switch index {
            case 0..<Self.parameterCount: return storage[index]
            default: fatalError("Index out of bounds")
            }
        }
        
        /*
        public init(initial: Initial, difficulty: Difficulty, stability: Stability) {
            self.initial = initial
            self.difficulty = difficulty
            self.stability = stability
        }
         */
        
        public init(parameters: [Double]) {
            guard parameters.count == Self.parameterCount else {
                self = .standard
                return
            }
            
            self.storage = parameters
            
            /*
            self.initial = Initial(parameters: Array(parameters[0...5]))
            self.difficulty = Difficulty(parameters: Array(parameters[6...7]))
            self.stability = Stability(parameters: Array(parameters[8...18]))
             */
        }
        
        /*
        public struct Initial: Codable {
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
            
            public struct Stability: Codable {
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
            
            public struct Difficulty: Codable {
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
        
        public struct Difficulty: Codable {
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
        
        public struct Stability: Codable {
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
            
            public struct Success: Codable {
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
            
            public struct Fail: Codable {
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
            
            public struct Multiplier: Codable {
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
            
            public struct ShortTerm: Codable {
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
         */
    }
}

// MARK: - Conformance

extension AnkiFSRS: Equatable {
    public static func == (lhs: AnkiFSRS, rhs: AnkiFSRS) -> Bool {
        lhs.storedDesiredRetention == rhs.storedDesiredRetention
        && lhs.storedParameters == rhs.storedParameters
    }
}

