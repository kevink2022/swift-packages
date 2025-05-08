//
//  SetSubtractable.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/10/25.
//


public protocol SetSubtractable {
    associatedtype Element
    
    @discardableResult
    mutating func remove(_ member: Element) -> Element?
}

extension SetSubtractable {
    
    public mutating func remove(_ contentsOf: [Element]) {
        for element in contentsOf { self.remove(element) }
    }
    
    public func removing(_ element: Element) -> Self {
        var new = self
        new.remove(element)
        return new
    }
    
    public func removing(_ contentsOf: [Element]) -> Self {
        var new = self
        new.remove(contentsOf)
        return new
    }
}
