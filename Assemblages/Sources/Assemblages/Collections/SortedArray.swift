//
//  File.swift
//  
//
//  Created by Kevin Kelly on 11/15/24.
//

import Foundation

/// Sorted array is an array that maintains a sorted order. This reduces lookup time to `O(log n)`.
public struct SortedArray<Element: Comparable> {
    
    public init(
        _ contentsOf: [Element] = []
        , sortOption: DuplicateInsertSortingOption = .any
        
    ) {
        self.storage = SortedArrayIndex(
            lessThan: <
            , equalTo: ==
            , sortOption: .any
            , contentsOf: contentsOf.sorted()
        )
    }
    
    internal var storage: SortedArrayIndex<Element>
    
    public var values: [Element] { storage.values }
    public var count: Int { storage.count }
    
    public subscript(index: Int) -> Element {
        return storage[index]
    }
    
    public mutating func insert(_ newMember: Element) { storage.insert(newMember) }
    public func inserting(_ newMember: Element) -> Self {
        var newArray = self
        newArray.insert(newMember)
        return newArray
    }
    
    public mutating func insert(_ contentsOf: [Element]) { storage.insert(contentsOf) }
    public func inserting(_ contentsOf: [Element]) -> Self {
        var newArray = self
        newArray.insert(contentsOf)
        return newArray
    }
    
    public mutating func merge(with array: SortedArray<Element>) {
        let newArray = SortingLogic.merge(array.values, into: storage.values, overwrite: false)
        storage.quickLoad(elements: newArray)
    }
    
    public func merging(with array: SortedArray<Element>) -> Self {
        let newArray = SortingLogic.merge(array.values, into: storage.values, overwrite: false)
        var newSortedArray = self
        newSortedArray.storage.quickLoad(elements: newArray)
        return newSortedArray
    }
}

extension SortedArray: ArraySubtractableImpl {
    var subtractableArray: [Element] {
        get { storage.storage }
        set { storage.storage = newValue }
    }
}
/*
extension SortedArray: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Element
    
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}
*/
extension SortedArray: Codable where Element: Codable {
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

