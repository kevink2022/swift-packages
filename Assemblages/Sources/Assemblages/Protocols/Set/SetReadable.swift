//
//  SetReadable.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/10/25.
//

public protocol SetReadable {
    associatedtype Element
    
    var count: Int { get }
    
    func contains(_ member: Element) -> Bool
}

extension SetReadable {
    public var isEmpty: Bool { count == 0 }
}
