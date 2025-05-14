//
//  SpacedRepetitionTests.swift
//  Domain
//
//  Created by Kevin Kelly on 5/14/25.
//

import XCTest
@testable import Domain

final class SpacedRepetitionTests: XCTestCase {
    
    // MARK: - Test Scaffolding
    
    /// Generic function to test any spaced repetition algorithm
    func scaffold_testAlgorithm<Algorithm: SpacedRepetitionAlgorithm>(
        algorithm: Algorithm,
        initialState: Algorithm.StateContext?,
        reviews: [(review: Algorithm.ReviewContext, expectedDate: Date, expectedState: Algorithm.StateContext?, tolerance: TimeInterval)],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var currentState = initialState
        
        for (index, testCase) in reviews.enumerated() {
            let result = algorithm.nextReview(state: currentState, review: testCase.review)
            
            // Test if the expected date is within tolerance
            let dateDifference = abs(result.nextReview.timeIntervalSince(testCase.expectedDate))
            
            print("Review \(index + 1): Next Review: \(result.nextReview) (\(dateDifference/86400))")
            
            XCTAssertLessThanOrEqual(
                dateDifference,
                testCase.tolerance,
                "Review \(index + 1) date should be within \(testCase.tolerance) seconds of expected date. Expected: \(testCase.expectedDate), Actual: \(result.nextReview)",
                file: file,
                line: line
            )
            
            // Test expected state if provided
            if let expectedState = testCase.expectedState {
                // Since we can't directly compare state objects (they don't conform to Equatable),
                // we'll validate key properties based on the algorithm type
                // Use type casting to validate specific algorithm state types
                switch (result.newState, expectedState) {
                    
                case let (actualState as SuperMemo2.State, expectedState as SuperMemo2.State):
                    // For SuperMemo2, validate interval and ease factor
                    XCTAssertEqual(
                        actualState.interval,
                        expectedState.interval,
                        accuracy: 0.001,
                        "Review \(index + 1): Interval should match expected value",
                        file: file,
                        line: line
                    )
                    XCTAssertEqual(
                        actualState.ease_factor,
                        expectedState.ease_factor,
                        accuracy: 0.001,
                        "Review \(index + 1): Ease factor should match expected value",
                        file: file,
                        line: line
                    )
                    
                case let (actualState as LinearSpacedRepetition.State, expectedState as LinearSpacedRepetition.State): break
                    
                default:
                    XCTFail("Unsupported state type combination for validation", file: file, line: line)
                }
            }
            
            // Update state for next iteration
            currentState = result.newState
        }
    }
    
    /// Generic function to test the type-erased version of a spaced repetition algorithm
    func scaffold_testTypeErasedAlgorithm<Algorithm: SpacedRepetitionAlgorithm>(
        algorithm: Algorithm,
        anyAlgorithm: AnySpacedRepetition,
        initialState: Algorithm.StateContext?,
        reviews: [(review: Algorithm.ReviewContext, expectedDate: Date, expectedState: Algorithm.StateContext?, tolerance: TimeInterval)],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let typeErasedReviews = reviews.map { review, expectedDate, _, tolerance in
            (
                review: AnySpacedRepetitionContext(review),
                expectedDate: expectedDate,
                tolerance: tolerance
            )
        }
        
        var currentState: AnySpacedRepetitionContext? = initialState.map { AnySpacedRepetitionContext($0) }
        
        for (index, testCase) in typeErasedReviews.enumerated() {
            
            if let result = anyAlgorithm.nextReview(state: currentState, review: testCase.review) {
                
                let dateDifference = abs(result.nextReview.timeIntervalSince(testCase.expectedDate))
               
                XCTAssertLessThanOrEqual(
                    dateDifference,
                    testCase.tolerance,
                    "Type-erased review \(index) date should be within \(testCase.tolerance) seconds of expected date. Expected: \(testCase.expectedDate), Actual: \(result.nextReview)",
                    file: file,
                    line: line
                )
                
                currentState = result.newState
            }
            
            else {
                XCTFail("Type-erased review \(index) did not return a value.")
            }
        }
    }
    
    // MARK: - SuperMemo-2 Tests
    
    func testSuperMemo2Algorithm() {
        let baseDate = makeDate(year: 2025, month: 5, day: 1, hour: 12)
        let algorithm = SuperMemo2()
        let anyAlgorithm = AnySpacedRepetition(algorithm)
        
        // Define test data
        let initialState: SuperMemo2.State? = nil // First review has no prior state
        
        let dateTolerance: TimeInterval = 60
        

        // answers w/ quality = 4 (correct_after_hesitation) don't change the ef
        let constant_ef_reviews: [(
            review: SuperMemo2.Review
            , expectedDate: Date
            , expectedState: SuperMemo2.State?
            , tolerance: TimeInterval
        )] = [
            (
                SuperMemo2.Review(date: baseDate, response: .correct_after_hesitation),
                baseDate.adding(.days(1))!,
                
                SuperMemo2.State(
                    interval: 1.0 // Interval 1 should always be 1 day
                    , ease_factor: 2.5
                ),
                dateTolerance
            )
            
            , (
                SuperMemo2.Review(date: baseDate.adding(.days(1))!, response: .correct_after_hesitation),
                baseDate.adding(.days(7))!, // 1 + 6 = 7
                SuperMemo2.State(
                    interval: 6.0 // Interval 2 should always be 6 days
                    , ease_factor: 2.5
                ),
                dateTolerance
            )
            
            , (
                SuperMemo2.Review(date: baseDate.adding(.days(7))!, response: .correct_after_hesitation),
                baseDate.adding(.days(22))!, // 7 + 15 = 22,
                SuperMemo2.State(
                    interval: 15.0 // 6 * 2.5 = 15
                    , ease_factor: 2.5),
                dateTolerance
            )
            
            
            , (
                SuperMemo2.Review(date: baseDate.adding(.days(22))!, response: .correct_after_hesitation),
                baseDate.adding(.days(59))!, // 22 + 37.5 = 59.5 (rounded to 60)
                SuperMemo2.State(
                    interval: 37.5 // 15 * 2.5 = 37.5
                    , ease_factor: 2.5),
                dateTolerance
            )
            
                   
            , (
                SuperMemo2.Review(date: baseDate.adding(.days(59))!, response: .correct_after_hesitation),
                baseDate.adding(.days(152))!, // 59.5 (rounded to 59) + 93.75 = 152.75 (rounded to 152)
                SuperMemo2.State(
                    interval: 93.75 // 37.5 * 2.5 = 93.75
                    , ease_factor: 2.5),
                dateTolerance
            )
        ]
        
        // Run the test with our generic scaffolding
        scaffold_testAlgorithm(
            algorithm: algorithm,
            initialState: initialState,
            reviews: constant_ef_reviews
        )
        
        // Also test the type-erased version to ensure it works the same way
        scaffold_testTypeErasedAlgorithm(
            algorithm: algorithm,
            anyAlgorithm: anyAlgorithm,
            initialState: initialState,
            reviews: constant_ef_reviews
        )
        
        let perfectReviews: [(
            review: SuperMemo2.Review
            , expectedDate: Date
            , expectedState: SuperMemo2.State?
            , tolerance: TimeInterval
        )] = [
            
        ]
    }
    
    func testLinear() {
        let baseDate = makeDate(year: 2025, month: 5, day: 1, hour: 12)
        let algorithm = LinearSpacedRepetition(spacing: .days(1))
        let anyAlgorithm = AnySpacedRepetition(algorithm)
        
        // Define test data
        let initialState: LinearSpacedRepetition.State? = nil // First review has no prior state
        
        let dateTolerance: TimeInterval = 60
        
        let reviews: [(
            review: LinearSpacedRepetition.Review
            , expectedDate: Date
            , expectedState: LinearSpacedRepetition.State?
            , tolerance: TimeInterval
        )] = [
            (
                LinearSpacedRepetition.Review(date: baseDate),
                baseDate.adding(.days(1))!,
                LinearSpacedRepetition.State(),
                dateTolerance
            )
            
            , (
                LinearSpacedRepetition.Review(date: baseDate.adding(.days(1))!),
                baseDate.adding(.days(2))!,
                LinearSpacedRepetition.State(),
                dateTolerance
            )
            
            , (
                LinearSpacedRepetition.Review(date: baseDate.adding(.days(2))!),
                baseDate.adding(.days(3))!,
                LinearSpacedRepetition.State(),
                dateTolerance
            )
            
            , (
                LinearSpacedRepetition.Review(date: baseDate.adding(.days(3))!),
                baseDate.adding(.days(4))!,
                LinearSpacedRepetition.State(),
                dateTolerance
            )
            
            , (
                LinearSpacedRepetition.Review(date: baseDate.adding(.days(4))!),
                baseDate.adding(.days(5))!,
                LinearSpacedRepetition.State(),
                dateTolerance
            )
        ]
        
        // Run the test with our generic scaffolding
        scaffold_testAlgorithm(
            algorithm: algorithm,
            initialState: initialState,
            reviews: reviews
        )
        
        // Also test the type-erased version to ensure it works the same way
        scaffold_testTypeErasedAlgorithm(
            algorithm: algorithm,
            anyAlgorithm: anyAlgorithm,
            initialState: initialState,
            reviews: reviews
        )
    }
    
    // MARK: - Helper Methods
    
    /// Helper method to create a date with specific components
    func makeDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return Calendar.current.date(from: components)!
    }
}
