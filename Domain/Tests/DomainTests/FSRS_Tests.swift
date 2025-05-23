//
//  FSRS_Tests.swift
//  Domain
//
//  Created by Kevin Kelly on 5/22/25.
//

import XCTest
@testable import Domain

final class FSRS_Tests: XCTestCase {
    
    let accuracy: Double = 0.0001
    
    func test_desired_retriveability_value() {
        let sut = AnkiFSRS()
        let sut_custom = AnkiFSRS(desiredRetention: 0.8)
        
        XCTAssertEqual(sut.desiredRetention, 0.9)
        XCTAssertEqual(sut_custom.desiredRetention, 0.8)
    }
    
    func test_decay_factor_values() {
        let w: AnkiFSRS.Parameters = .standard
        let w_test: AnkiFSRS.Parameters = .init(parameters: [Double](repeating: 0.5, count: 21))
        
        let sut = AnkiFSRS()
        let sut_custom = AnkiFSRS(parameters: w_test)
        
        XCTAssertEqual(sut.decay, -0.2)
        XCTAssertEqual(sut.factor, 0.6935087808, accuracy: accuracy)

        XCTAssertEqual(sut_custom.decay, -0.5)
        XCTAssertEqual(sut_custom.factor, 0.2345679012, accuracy: accuracy)
    }
    
    func test_param_values() {
        let w: AnkiFSRS.Parameters = .standard
        let w_test: AnkiFSRS.Parameters = .init(parameters: [Double](repeating: 0.5, count: 21))
        
        let sut = AnkiFSRS()
        let sut_custom = AnkiFSRS(parameters: w_test)

        XCTAssertEqual(sut.parameters.storage, w.storage)
        XCTAssertEqual(sut_custom.parameters.storage, w_test.storage)
    }
    
    func test_initial_stability() {
        let w: AnkiFSRS.Parameters = .standard
        let sut = AnkiFSRS()
        
        let custom_w = [0.0, 0.1, 0.2, 0.3] + Array(repeating: 0.5, count: 17)
        let sut_custom = AnkiFSRS(parameters: AnkiFSRS.Parameters(parameters: custom_w))
        
        XCTAssertEqual(sut.initialStability(grade: .forgot), w[0])
        XCTAssertEqual(sut.initialStability(grade: .hard), w[1])
        XCTAssertEqual(sut.initialStability(grade: .good), w[2])
        XCTAssertEqual(sut.initialStability(grade: .easy), w[3])
        
        XCTAssertEqual(sut_custom.initialStability(grade: .forgot), 0.0)
        XCTAssertEqual(sut_custom.initialStability(grade: .hard), 0.1)
        XCTAssertEqual(sut_custom.initialStability(grade: .good), 0.2)
        XCTAssertEqual(sut_custom.initialStability(grade: .easy), 0.3)
    }
    
    func test_initial_difficulty() {
        let sut = AnkiFSRS()
        
        let test_w4 = 6.0
        let test_w5 = 0.6
        let custom_w = Array(repeating: 0.4, count: 4) + [test_w4, test_w5] + Array(repeating: 0.7, count: 15)
        let sut_custom = AnkiFSRS(parameters: AnkiFSRS.Parameters(parameters: custom_w))
        
        XCTAssertEqual(sut.initialDifficulty(grade: .forgot), 7.0114, accuracy: accuracy)
        XCTAssertEqual(sut.initialDifficulty(grade: .hard), 6.24313294857, accuracy: accuracy)
        XCTAssertEqual(sut.initialDifficulty(grade: .good), 4.88463163481, accuracy: accuracy)
        XCTAssertEqual(sut.initialDifficulty(grade: .easy), 2.48243852238, accuracy: accuracy)
        
        XCTAssertEqual(sut_custom.initialDifficulty(grade: .forgot), 6)
        XCTAssertEqual(sut_custom.initialDifficulty(grade: .hard), 5.17788119961, accuracy: accuracy)
        XCTAssertEqual(sut_custom.initialDifficulty(grade: .good), 3.67988307726, accuracy: accuracy)
        XCTAssertEqual(sut_custom.initialDifficulty(grade: .easy), /*0.950352535587*/1, accuracy: accuracy) //clamped to 1
    
    }
    
    func test_next_interval() {
        let test_stability = 10.0
        let test_state = AnkiFSRS.State(difficulty: 0, stability: test_stability, lastReviewed: .now)
        
        let sut = AnkiFSRS()
        let sut_custom = AnkiFSRS(desiredRetention: 0.8)
        
        XCTAssertEqual(sut.nextInterval(state: test_state), test_stability, accuracy: accuracy)
        XCTAssertEqual(sut_custom.nextInterval(state: test_state), 29.5851742498, accuracy: accuracy)
    }
    
    func test_retrievability_after_interval() {
        let w_test: AnkiFSRS.Parameters = .init(parameters: [Double](repeating: 0.5, count: 21))

        let test_stability = 10.0
        let test_interval = 20.0
        let test_state = AnkiFSRS.State(difficulty: 0, stability: test_stability, lastReviewed: .now)
        
        let sut = AnkiFSRS()
        let sut_custom = AnkiFSRS(parameters: w_test)
        
        XCTAssertEqual(sut.retrievability(state: test_state, interval: test_interval), 0.840289384673, accuracy: accuracy)
        XCTAssertEqual(sut_custom.retrievability(state: test_state, interval: test_interval), 0.825028647325, accuracy: accuracy)
    }
    
    func test_difficulty_delta() {
        let w6_test = 2.0
        let w_test = Array(repeating: 0.4, count: 6) + [w6_test] + Array(repeating: 0.7, count: 14)
        
        let sut = AnkiFSRS()
        let sut_custom = AnkiFSRS(parameters: AnkiFSRS.Parameters(parameters: w_test))
        
        XCTAssertEqual(sut.difficultyDelta(grade: .forgot), 4.1932)
        XCTAssertEqual(sut.difficultyDelta(grade: .hard), 2.0966)
        XCTAssertEqual(sut.difficultyDelta(grade: .good), 0)
        XCTAssertEqual(sut.difficultyDelta(grade: .easy), -2.0966)
        
        XCTAssertEqual(sut_custom.difficultyDelta(grade: .forgot), 4)
        XCTAssertEqual(sut_custom.difficultyDelta(grade: .hard), 2)
        XCTAssertEqual(sut_custom.difficultyDelta(grade: .good), 0)
        XCTAssertEqual(sut_custom.difficultyDelta(grade: .easy), -2)
    }
    
    func test_difficulty_prime() {
        let difficulty_test = 3.0
        let state_test = AnkiFSRS.State(difficulty: difficulty_test, stability: 0, lastReviewed: .now)
        let w6_test = 2.0
        let w_test = Array(repeating: 0.4, count: 6) + [w6_test] + Array(repeating: 0.7, count: 14)
        
        let sut = AnkiFSRS()
        let sut_custom = AnkiFSRS(parameters: AnkiFSRS.Parameters(parameters: w_test))
        
        XCTAssertEqual(sut.difficultyPrime(state: state_test, grade: .forgot), 6.26137777778, accuracy: accuracy)
        XCTAssertEqual(sut.difficultyPrime(state: state_test, grade: .hard), 4.63068888889, accuracy: accuracy)
        XCTAssertEqual(sut.difficultyPrime(state: state_test, grade: .good), difficulty_test, accuracy: accuracy)
        XCTAssertEqual(sut.difficultyPrime(state: state_test, grade: .easy), 1.36931111111, accuracy: accuracy)
        
        XCTAssertEqual(sut_custom.difficultyPrime(state: state_test, grade: .forgot), 6.11111111111, accuracy: accuracy)
        XCTAssertEqual(sut_custom.difficultyPrime(state: state_test, grade: .hard), 4.55555555556, accuracy: accuracy)
        XCTAssertEqual(sut_custom.difficultyPrime(state: state_test, grade: .good), difficulty_test, accuracy: accuracy)
        XCTAssertEqual(sut_custom.difficultyPrime(state: state_test, grade: .easy), 1.44444444444, accuracy: accuracy)
    }
    
    // Not going to test custom params from here on out.
    func test_difficulty_after_review() {
        let difficulty_test = 3.0
        let state_test = AnkiFSRS.State(difficulty: difficulty_test, stability: 0, lastReviewed: .now)
        
        let sut = AnkiFSRS()
        
        XCTAssertEqual(sut.difficultyAfterReview(state: state_test, grade: .forgot), 6.23530309692, accuracy: accuracy)
        XCTAssertEqual(sut.difficultyAfterReview(state: state_test, grade: .hard), 4.61586596136, accuracy: accuracy)
        XCTAssertEqual(sut.difficultyAfterReview(state: state_test, grade: .good), 2.9964288258, accuracy: accuracy)
        XCTAssertEqual(sut.difficultyAfterReview(state: state_test, grade: .easy), 1.37699169025, accuracy: accuracy)
        
    }
        
    func test_stability_after_review() {
        let difficulty_test = 5.0
        let stability_test = 10.0
        let state_test = AnkiFSRS.State(difficulty: difficulty_test, stability: stability_test, lastReviewed: .now)
        /*
        let w8_test = 2.0
        let w9_test = 2.0
        let w10_test = 2.0
        let w15_test = 2.0
        let w16_test = 2.0
        
        let w_test = Array(repeating: 0.4, count: 8)
            + [w8_test, w9_test, w10_test]
            + Array(repeating: 0.7, count: 4)
            + [w15_test, w16_test]
            + Array(repeating: 0.7, count: 4)
         */
        
        let sut = AnkiFSRS()
        
        // if the interval == stability, retrievability == 0.9, which is the value being tested
                
        // forgot
        XCTAssertEqual(sut.stabilityAfterForgot(interval: stability_test, state: state_test), 2.16397002381, accuracy: accuracy)
        
        // remembered
        XCTAssertEqual(sut.stabilityAfterRemembered(interval: stability_test, state: state_test, grade: .hard), 15.0063541538, accuracy: accuracy)
        XCTAssertEqual(sut.stabilityAfterRemembered(interval: stability_test, state: state_test, grade: .good), 32.8496310076, accuracy: accuracy)
        XCTAssertEqual(sut.stabilityAfterRemembered(interval: stability_test, state: state_test, grade: .easy), 78.5580328753, accuracy: accuracy)
        
        // short term (same day)
        XCTAssertEqual(sut.stabilityShortTerm(state: state_test, grade: .forgot), 2.04541997494, accuracy: accuracy)
        XCTAssertEqual(sut.stabilityShortTerm(state: state_test, grade: .hard), 4.34577076887, accuracy: accuracy)
        XCTAssertEqual(sut.stabilityShortTerm(state: state_test, grade: .good), 9.23317646592, accuracy: accuracy)
        XCTAssertEqual(sut.stabilityShortTerm(state: state_test, grade: .easy), 19.6171294311, accuracy: accuracy)
        
        /*
        let sut_custom = AnkiFSRS(parameters: AnkiFSRS.Parameters(parameters: w_test))

        XCTAssertEqual(sut_custom.difficultyPrime(state: state_test, grade: .forgot), 6.2424830815)
        XCTAssertEqual(sut_custom.difficultyPrime(state: state_test, grade: .hard), 4.61994763706)
        XCTAssertEqual(sut_custom.difficultyPrime(state: state_test, grade: .good), 2.99741219261)
        XCTAssertEqual(sut_custom.difficultyPrime(state: state_test, grade: .easy), 1.37487674817)
         */
    }
    /*
    func test_stability_after_fail() {
        let difficulty_test = 5.0
        let stability_test = 10.0
        let state_test = AnkiFSRS.State(difficulty: difficulty_test, stability: stability_test, lastReviewed: .now)
        let w12_test = 2.0
        let w13_test = 2.0
        let w14_test = 2.0
        let w_test = Array(repeating: 0.4, count: 11) + [w12_test, w13_test, w14_test] + Array(repeating: 0.7, count: 7)
        
    }
    
    func test_stability_after_short() {
        let difficulty_test = 3.0
        let stability_test = 10.0
        let state_test = AnkiFSRS.State(difficulty: difficulty_test, stability: 0, lastReviewed: .now)
        let w17_test = 2.0
        let w18_test = 2.0
        let w19_test = 2.0
        let w_test = Array(repeating: 0.4, count: 16) + [w17_test, w18_test, w19_test] + Array(repeating: 0.7, count: 1)
        
    }
    */  
}
