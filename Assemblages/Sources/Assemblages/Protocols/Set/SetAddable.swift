//
//  SetAddable.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/10/25.
//

public protocol SetAddable {
    associatedtype Element
    
    @discardableResult
    mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element)
    
    @discardableResult
    mutating func update(with newMember: Element) -> Element?
}

extension SetAddable {
    public mutating func insert(_ contentsOf: [Element]) {
        for element in contentsOf { self.insert(element) }
    }
    
    public func inserting(_ newMember: Element) -> Self {
        var new = self
        new.insert(newMember)
        return new
    }
    
    public func inserting(_ contentsOf: [Element]) -> Self {
        var new = self
        new.insert(contentsOf)
        return new
    }
    
    public mutating func update(with contentsOf: [Element]) {
        for element in contentsOf { self.update(with: element) }
    }
    
    public func updating(with newMember: Element) -> Self {
        var new = self
        new.update(with: newMember)
        return new
    }
    
    public func updating(with contentsOf: [Element]) -> Self {
        var new = self
        new.update(with: contentsOf)
        return new
    }
}
