//
//  SortedArrayIndex.swift
//  Assemblages
//
//  Created by Kevin Kelly on 11/26/24.
//

import Foundation

public struct SortedArrayIndex<Element> {
    
    public init(
        lessThan: @escaping (Element, Element) -> Bool
        , equalTo: ((Element, Element) -> Bool)? = nil
        , sortOption: DuplicateInsertSortingOption = .any
        , contentsOf elements: [Element] = []
    ) {
        self.init(
            lessThan: lessThan
            , equalTo: equalTo ?? { !lessThan($0, $1) && !lessThan($1, $0) }
            , quickLoad: elements.sorted(by: { lessThan($0, $1) } )
            , sortOption: sortOption
        )
    }
    
    
    
    internal var storage: [Element] = []
    
    internal let lessThan: (Element, Element) -> Bool
    internal let equalTo: (Element, Element) -> Bool
    
    internal let sortOption: DuplicateInsertSortingOption
    internal let binarySearchFor: (Element, [Element]) -> (index: Int, exists: Bool)
    
    public var values: [Element] { storage }
    public var count: Int { storage.count }
    
    public subscript(index: Int) -> Element { storage[index] }

    public mutating func insert(_ newMember: Element) {
        let result = binarySearchFor(newMember, storage)
        storage.insert(newMember, at: result.index)
    }
    
    public func inserting(_ newMember: Element) -> Self {
        var newArray = self
        let result = binarySearchFor(newMember, storage)
        newArray.insert(newMember)
        return newArray
    }
    
    public mutating func insert(_ contentsOf: [Element]) {
        for newMember in contentsOf { insert(newMember) }
    }
    
    public func inserting(_ contentsOf: [Element]) -> Self {
        var newArray = self
        newArray.insert(contentsOf)
        return newArray
    }
}

extension SortedArrayIndex: ArraySubtractableImpl {
    var subtractableArray: [Element] {
        get { storage }
        set { storage = newValue }
    }
}

/// Quickload doesn't sort the elements or remove dupes. assumes the array is already a valid sorted set.
extension SortedArrayIndex {
    
    private init(
        lessThan: @escaping (Element, Element) -> Bool
        , equalTo: @escaping (Element, Element) -> Bool
        , quickLoad elements: [Element]
        , sortOption: DuplicateInsertSortingOption = .any
    ) {
        self.lessThan = lessThan
        self.equalTo = equalTo
        self.storage = elements
        self.sortOption = sortOption
        
        self.binarySearchFor = { element, storage in
            SortingLogic.binarySearch(
                for: element
                , in: storage
                , equalTo: equalTo
                , lessThan: lessThan
                , option: sortOption
            )
        }
    }
    
    internal mutating func quickLoad(elements: [Element]) {
        storage = elements
    }
}
