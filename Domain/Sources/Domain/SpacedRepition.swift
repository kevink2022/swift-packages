////
////  SpacedRepition.swift
////  Domain
////
////  Created by Kevin Kelly on 2/14/25.
////
//
//import Foundation
//
//public protocol SpacedRepition: CaseIterable/*, Codable*/ {
//    associatedtype History: SpacedRepitionHistory
//    associatedtype Response
//    
//    func next(response: Response, history: [History]) -> Date
//}
//
//public protocol SpacedRepitionHistory {
//    var date: Date { get }
//    var response: SpacedRepitionResponse { get }
//}
//
//public final class SM2<History: SpacedRepitionHistory>: SpacedRepition {
//    
//    public enum Response {
//        case again
//        case hard
//        case good
//        case easy
//    }
//
//    public init(
//        history: [History]
//    ) {
//        self
//    }
//    
//    public let history: [History]
//
//    
//    typealias Response = SM2.Response
//    
//    public static func next(response: Response, history: [History]) -> Date {
//        
//    }
//    
//    private enum Stage {
//        case learning, case exponential
//    }
//    
//    private class Config {
//        let learningSteps: ()
//    }
//    
//    private let config:
//    private let stage: SM2.Stage
//    
//    private static func stage(_ history: [History]) -> {
//        history.count < 2
//    }
//}
