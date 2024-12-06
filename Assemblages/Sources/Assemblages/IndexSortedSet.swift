//
//  File.swift
//  
//
//  Created by Kevin Kelly on 11/19/24.
//

import Foundation

public struct IndexSortedSet<Element> {
    
    public init(
        lessThan: @escaping (Element, Element) -> Bool
        , equalTo: ((Element, Element) -> Bool)? = nil
        , contentsOf elements: [Element] = []
    ) {
        self.init(
            lessThan: lessThan
            , equalTo: equalTo ?? { !lessThan($0, $1) && !lessThan($1, $0) }
            , quickLoad: elements.sorted(by: { lessThan($0, $1) } )
        )
    }
    
    /// Quickload doesn't sort the elements or remove dupes. assumes the array is already a valid sorted set.
    private init(
        lessThan: @escaping (Element, Element) -> Bool
        , equalTo: @escaping (Element, Element) -> Bool
        , quickLoad elements: [Element]
    ) {
        self.lessThan = lessThan
        self.equalTo = equalTo
        self.storage = elements
    }
    
    internal var storage: [Element] = []
    
    internal let lessThan: (Element, Element) -> Bool
    internal let equalTo: (Element, Element) -> Bool
    
    public var values: [Element] { storage }
    public var count: Int { storage.count }
    
    public subscript(index: Int) -> Element {
        return storage[index]
    }
    
    public subscript(element: Element) -> Element? {
        let result = SortingLogic.binarySearch(
            for: element
            , in: storage
            , equalTo: equalTo
            , lessThan: lessThan
        )
        
        if result.exists {
            return storage[result.index]
        } else {
            return nil
        }
    }
    
    public mutating func insert(_ element: Element) {
        let result = SortingLogic.binarySearch(
            for: element
            , in: storage
            , equalTo: equalTo
            , lessThan: lessThan
        )
        
        if result.exists {
            storage[result.index] = element
        } else {
            storage.insert(element, at: result.index)
        }
    }
    
    public func inserting(_ element: Element) -> Self {
        var newSet = self
        newSet.insert(element)
        return newSet
    }
    
    public mutating func insert(contentsOf elements: [Element]) {
        for element in elements {
            insert(element)
        }
    }
    
    public func inserting(contentsOf elements: [Element]) -> Self {
        var newSet = self
        elements.forEach { element in
            newSet.insert(element)
        }
        return newSet
    }
    
    public mutating func remove(_ element: Element) {
        let result = SortingLogic.binarySearch(
            for: element
            , in: storage
            , equalTo: equalTo
            , lessThan: lessThan
        )
        
        if result.exists {
            storage.remove(at: result.index)
        }
    }
    
    public func removing(_ element: Element) -> Self {
        var newSet = self
        newSet.remove(element)
        return newSet
    }
    
    public mutating func remove(contentsOf elements: [Element]) {
        for element in elements {
            remove(element)
        }
    }
    
    public func removing(contentsOf elements: [Element]) -> Self {
        var newSet = self
        elements.forEach { element in
            newSet.remove(element)
        }
        return newSet
    }
}

extension IndexSortedSet where Element: Hashable {
    public init(
        lessThan: @escaping (Element, Element) -> Bool
        , equalTo: ((Element, Element) -> Bool)? = nil
        , contentsOf set: Set<Element>
    ) {
        self.init(
            lessThan: lessThan
            , equalTo: equalTo ?? { !lessThan($0, $1) && !lessThan($1, $0) }
            , quickLoad: set.sorted(by: { lessThan($0, $1) } )
        )
    }
}

extension IndexSortedSet: ArrayMutableCollectionImpl {
    public typealias Element = Element
}
