//
//  File.swift
//  
//
//  Created by Kevin Kelly on 11/19/24.
//

import Foundation

public struct SortedSetIndex<Element>: SetMutable {
       
    public init(
        lessThan: @escaping (Element, Element) -> Bool
        , equalTo: ((Element, Element) -> Bool)? = nil
        , sortOption: DuplicateInsertSortingOption = .any
        , contentsOf elements: [Element] = []
    ) {
        self.init(
            lessThan: lessThan
            , equalTo: equalTo ?? { !lessThan($0, $1) && !lessThan($1, $0) }
            , sortOption: sortOption
            , quickLoad: elements.sorted(by: { lessThan($0, $1) } )
        )
    }
    
    /// Quickload doesn't sort the elements or remove dupes. assumes the array is already a valid sorted set.
    private init(
        lessThan: @escaping (Element, Element) -> Bool
        , equalTo: @escaping (Element, Element) -> Bool
        , sortOption: DuplicateInsertSortingOption = .any
        , quickLoad elements: [Element]
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
    
    internal var storage: [Element] = []
    
    internal let lessThan: (Element, Element) -> Bool
    internal let equalTo: (Element, Element) -> Bool
    internal let sortOption: DuplicateInsertSortingOption
    
    internal let binarySearchFor: (Element, [Element]) -> (index: Int, exists: Bool)
    
    public var values: [Element] { storage }
    public var count: Int { storage.count }
    public var isEmpty: Bool { storage.isEmpty }
    
    public subscript(index: Int) -> Element {
        return storage[index]
    }
    
    public subscript(element: Element) -> Element? {
        let result = binarySearchFor(element, storage)
        if result.exists { return storage[result.index] }
        else { return nil }
    }
    
    public func contains(_ member: Element) -> Bool { binarySearchFor(member, storage).exists }
    
    @discardableResult
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let result = binarySearchFor(newMember, storage)
        
        if result.exists && equalTo(newMember, storage[result.index]) {
            return (false, storage[result.index])
        } else {
            storage.insert(newMember, at: result.index)
            return (true, newMember)
        }
    }
    
    @discardableResult
    public mutating func update(with newMember: Element) -> Element? {
        let result = binarySearchFor(newMember, storage)
        
        if result.exists && equalTo(newMember, storage[result.index]) {
            let oldMember = storage[result.index]
            storage[result.index] = newMember
            return oldMember
        } else {
            storage.insert(newMember, at: result.index)
            return nil
        }
    }
    
    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        let result = binarySearchFor(member, storage)
        
        guard result.exists else { return nil }
        
        let oldMember = storage[result.index]
        storage.remove(at: result.index)
        return oldMember
    }
}

extension SortedSetIndex where Element: Hashable {
    public init(
        lessThan: @escaping (Element, Element) -> Bool
        , equalTo: ((Element, Element) -> Bool)? = nil
        , sortOption: DuplicateInsertSortingOption = .any
        , contentsOf set: Set<Element>
    ) {
        self.init(
            lessThan: lessThan
            , equalTo: equalTo ?? { !lessThan($0, $1) && !lessThan($1, $0) }
            , sortOption: sortOption
            , quickLoad: set.sorted(by: { lessThan($0, $1) } )
        )
    }
}

extension SortedSetIndex: ArraySubtractableImpl {
    internal var subtractableArray: [Element] {
        get { storage }
        set { storage = newValue }
    }
}
