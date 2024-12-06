//
//  IndexSortedArray.swift
//  Assemblages
//
//  Created by Kevin Kelly on 11/26/24.
//

import Foundation

public struct IndexSortedArray<Element> {
    
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
    
    public mutating func insert(_ element: Element) {
        let result = SortingLogic.binarySearch(
            for: element
            , in: storage
            , equalTo: equalTo
            , lessThan: lessThan
        )
        
        storage.insert(element, at: result.index)
    }
    
    public func inserting(_ element: Element) -> Self {
        var newSet = self
        newSet.insert(element)
        return newSet
    }
    
    public mutating func insert(contentsOf elements: [Element]) {
        let elements = elements.sorted(by: lessThan)
        storage = SortingLogic.merge(
            elements
            , into: storage
            , lessThan: lessThan
            , overwrite: false
        )
    }
    
    public func inserting(contentsOf elements: [Element]) -> Self {
        var newSet = self
        let elements = elements.sorted(by: lessThan)
        newSet.storage = SortingLogic.merge(
            elements
            , into: storage
            , lessThan: lessThan
            , overwrite: false
        )
        return newSet
    }
}

extension IndexSortedArray: ArrayMutableCollectionImpl {
    public typealias Element = Element
}
