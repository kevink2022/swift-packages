//
//  File.swift
//  
//
//  Created by Kevin Kelly on 11/13/24.
//

import Foundation

/// The `ExternallySortedKeySet` is a `KeySet` that tracks sorting in an external array.
public struct ExternallySortedKeySet<Element: Identifiable> {
    
    public init(
        lessThan: @escaping (Element, Element) -> Bool
        , equalTo: ((Element, Element) -> Bool)? = nil
        , set: KeySet<Element> = KeySet<Element>()
    ) {
        self.keyed = set
        self.sorted = IndexSortedSet(
            lessThan: lessThan
            , equalTo: equalTo ?? { !lessThan($0, $1) && !lessThan($1, $0) }
            , contentsOf: set.values
        )
    }
    
    internal var keyed: KeySet<Element>
    internal var sorted: IndexSortedSet<Element>
    
    public var count: Int { sorted.count }
    public var values: [Element] { sorted.values }
    
    public subscript(id: Element.ID) -> Element? {
        return keyed[id]
    }
    
    public subscript(element: Element) -> Element? {
        return keyed[element.id]
    }
    
    //public subscript(index: Int) -> Element {
    //    return sorted[index]
    //}
    
    public mutating func insert(_ element: Element) {
        keyed.insert(element)
        sorted.insert(element)
    }
    
    public func inserting(_ element: Element) -> Self {
        var newSet = self
        newSet.insert(element)
        return newSet
    }
    
    public mutating func insert(contentsOf elements: [Element]) {
        sorted.insert(contentsOf: elements)
        keyed.insert(contentsOf: elements)
    }
    
    public func inserting(contentsOf elements: [Element]) -> Self {
        var newSet = self
        newSet.insert(contentsOf: elements)
        return newSet
    }
    
    public mutating func remove(_ element: Element) {
        keyed.remove(element)
        sorted.remove(element)
    }
    
    public func removing(_ element: Element) -> Self {
        var newSet = self
        newSet.remove(element)
        return newSet
    }
    
    public mutating func remove(contentsOf elements: [Element]) {
        keyed.remove(contentsOf: elements)
        sorted.remove(contentsOf: elements)
    }
    
    public func removing(contentsOf elements: [Element]) -> Self {
        var newSet = self
        newSet.remove(contentsOf: elements)
        return newSet
    }
    
    public func contains(_ element: Element) -> Bool {
        return keyed[element.id] != nil
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
        var newSet = self
        newSet.keyed.removeAll()
        newSet.sorted.removeAll()
        for element in sorted.storage {
            if try isIncluded(element) {
                newSet.insert(element)
            }
        }
        return newSet
    }
}

extension ExternallySortedKeySet: ArrayReadableCollectionImpl {
   
    public typealias Element = Element
    
    public var storage: [Element] {
        get { sorted.storage }
        set { sorted.storage = newValue }
    }
}
