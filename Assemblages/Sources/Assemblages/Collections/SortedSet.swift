//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/20/24.
//

import Foundation

public struct SortedSet<Element: Comparable>: SetMutable {
    
    public init(
        _ contentsOf: [Element] = []
        , sortOption: DuplicateInsertSortingOption = .any
    ) {
        self.storage = SortedSetIndex(
            lessThan: <
            , equalTo: ==
            , sortOption: sortOption
        )
    }
    
    internal var storage: SortedSetIndex<Element>
    
    public var isEmpty: Bool { storage.isEmpty }
    public var values: [Element] { storage.values }
    public var count: Int { storage.count }
    
    public subscript(index: Int) -> Element { storage[index] }
    public subscript(element: Element) -> Element? { storage[element] }
    
    public func contains(_ member: Element) -> Bool { storage.contains(member) }
    
    @discardableResult
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        storage.insert(newMember)
    }
    
    @discardableResult
    public mutating func update(with newMember: Element) -> Element? {
        storage.update(with: newMember)
    }
    
    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        storage.remove(member)
    }
}

extension SortedSet: ArraySubtractableImpl {
    var subtractableArray: [Element] {
        get { storage.storage }
        set { storage.storage = newValue }
    }
}

extension SortedSet: Codable where Element: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage.values)
    }
    
    public init(from decoder: Decoder) throws {
        guard
            let container = try? decoder.container(keyedBy: CodingKeys.self)
            , let elements = try? container.decode([Element].self, forKey: .elements)
        else {
           // Fall back to unkeyed (array)
           var arrayContainer = try decoder.unkeyedContainer()
           let elements = try arrayContainer.decode([Element].self)
           self.init(elements, sortOption: .any)
           return
        }
        
        let sortOption = (try? container.decode(DuplicateInsertSortingOption.self, forKey: .sortOption)) ?? .any
        self.init(elements, sortOption: sortOption)
    }
    
    private enum CodingKeys: String, CodingKey {
        case elements
        case sortOption
    }
}

/*
extension SortedSet where Element: Hashable {
    public init(set: Set<Element>) {
        self.storage.storage = set.sorted()
    }
}
*/

extension SortedSet: Equatable where Element: Equatable {
    public static func == (lhs: SortedSet, rhs: SortedSet) -> Bool {
        lhs.storage.storage == rhs.storage.storage
    }
}


//
//extension SortedSet: ArrayReadableImpl {
//    internal var readableArray: [Element] { storage.values }
//}

/*

/// Sorted set is a set that maintains a sorted order. This reduces lookup time to `O(log n)`.
public struct SortedSet<Element: Comparable> {
    
    public init() {
        self.storage = []
    }
    
    public init(contentsOf elements: [Element]) {
        self.storage = elements.sorted().reduce(into: []) { uniqueElements, currentElement in
            if uniqueElements.last != currentElement {
                uniqueElements.append(currentElement)
            }
        }
    }
    
    /// Quickload doesn't sort the elements or remove dupes. assumes the array is already a valid sorted set.
    private init(quickLoad elements: [Element]) {
        self.storage = elements
    }
    
    internal var storage: [Element] = []
    
    public var values: [Element] { storage }
    public var count: Int { storage.count }
    
    public subscript(index: Int) -> Element {
        return storage[index]
    }
    
    public subscript(element: Element) -> Element? {
        let result = SortingLogic.binarySearch(for: element, in: storage)
        if result.exists {
            return storage[result.index]
        } else {
            return nil
        }
    }
    
    public mutating func insert(_ element: Element) {
        let result = SortingLogic.binarySearch(for: element, in: storage)
        if result.exists {
            storage[result.index] = element
        } else {
            storage.insert(element, at: result.index)
        }
    }
        
    public mutating func union(_ set: SortedSet<Element>) {
        storage = SortingLogic.merge(set.values, into: storage, overwrite: true)
    }
    
    public func unioning(_ set: SortedSet<Element>) -> Self {
        return SortedSet<Element>(
            quickLoad: SortingLogic.merge(set.values, into: self.values, overwrite: true)
        )
    }
    
    public mutating func remove(_ element: Element) {
        let result = SortingLogic.binarySearch(for: element, in: storage)
        if result.exists {
            storage.remove(at: result.index)
        }
    }
}


extension SortedSet: Codable where Element: Codable { }
extension SortedSet: ArrayMutableCollectionImpl {
    public typealias Element = Element
}
 */
