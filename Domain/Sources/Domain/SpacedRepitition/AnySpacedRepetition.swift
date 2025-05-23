//
//  AnySpacedRepetition.swift
//  Domain
//
//  Created by Kevin Kelly on 5/11/25.
//

import Foundation

public struct AnySpacedRepetition/*: SpacedRepetitionAlgorithm */{
    /*public typealias StateContext = AnySpacedRepetitionContext
    public typealias ReviewContext = AnySpacedRepetitionContext*/
    
    public func nextReview(state: AnySpacedRepetitionContext?, review: AnySpacedRepetitionContext) -> (nextReview: Date, newState: AnySpacedRepetitionContext)? {
        data.typeErasedNextReview(state: state, review: review)
    }
    
    public var code: SpacedRepetitionAlgorithmCode { data.code }
    
    internal let data: any SpacedRepetitionAlgorithm
    
    public init(_ data: any SpacedRepetitionAlgorithm) {
        /*if let data = data as? AnySpacedRepetition {  self.data = data.data }*/
        self.data = data
    }
}

public struct AnySpacedRepetitionContext: SpacedRepetitionContext {
    public init(_ data: any SpacedRepetitionContext) {
        if let data = data as? AnySpacedRepetitionContext {  self.data = data.data }
        else { self.data = data }
    }
    
    public let data: any SpacedRepetitionContext
    
    public var code: SpacedRepetitionContextCode { data.code }
}

extension SpacedRepetitionAlgorithm {
    internal func typeErasedNextReview(state: AnySpacedRepetitionContext?, review: AnySpacedRepetitionContext) -> (nextReview: Date, newState: AnySpacedRepetitionContext)? {
        
        guard let review = review.data as? Self.ReviewContext else { return nil }
        if let state = state, !(state.data is Self.StateContext) { return nil }
        
        let state = state?.data as? Self.StateContext
        
        let (nextReview, newState) = self.nextReview(state: state, review: review)
        
        return (nextReview, AnySpacedRepetitionContext(newState))
    }
}


// MARK: - Coding Boilerplate
extension AnySpacedRepetition {
    internal init(code: SpacedRepetitionAlgorithmCode) {
        switch code {
        case .linear(let data): self.init(data)
        case .leitnerBox(let data): self.init(data)
        case .superMemo2(let data): self.init(data)
        case .ankiFSRS_5(let data): self.init(data)
        case .wanikaniSRS(let data): self.init(data)
        }
    }
    
    internal enum CodingKeys: String, CodingKey { case code }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data.code, forKey: .code)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decode(SpacedRepetitionAlgorithmCode.self, forKey: .code)
        self.init(code: code)
    }
}

extension AnySpacedRepetitionContext {
    internal init(code: SpacedRepetitionContextCode) {
        switch code {
        case .linear_state(let data): self.init(data)
        case .leitnerBox_state(let data): self.init(data)
        case .superMemo2_state(let data): self.init(data)
        case .ankiFSRS_state(let data): self.init(data)
        case .wanikaniSRS_state(let data): self.init(data)
        case .linear_review(let data): self.init(data)
        case .leitnerBox_review(let data): self.init(data)
        case .superMemo2_review(let data): self.init(data)
        case .ankiFSRS_review(let data): self.init(data)
        case .wanikaniSRS_review(let data): self.init(data)
        }
    }
    
    internal enum CodingKeys: String, CodingKey { case code }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data.code, forKey: .code)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decode(SpacedRepetitionContextCode.self, forKey: .code)
        self.init(code: code)
    }
}
