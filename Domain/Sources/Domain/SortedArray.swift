//
//  File.swift
//  
//
//  Created by Kevin Kelly on 11/15/24.
//

import Foundation

/// Sorted set is a set that maintains a sorted order. This reduces lookup time to `O(log n)`.
public struct SortedArray<Element: Comparable> {
    
    public init() {
        self.storage = []
    }
    
    public init(contentsOf elements: [Element]) {
        self.storage = elements.sorted()
    }
    
    /// Quickload doesn't sort the elements.
    private init(quickLoad elements: [Element]) {
        self.storage = elements
    }
    
    internal var storage: [Element] = []
    
    public var values: [Element] { storage }
    public var count: Int { storage.count }
    
    public subscript(index: Int) -> Element {
        return storage[index]
    }
    
    public mutating func insert(_ element: Element) {
        let result = SortingLogic.binarySearch(for: element, in: storage)
        storage.insert(element, at: result.index)
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
    
    public mutating func merge(with array: SortedArray<Element>) {
        storage = SortingLogic.merge(array.values, into: storage)
    }
    
    public func merging(with array: SortedArray<Element>) -> Self {
        return SortedArray(quickLoad: SortingLogic.merge(array.values, into: storage))
    }
    
    public mutating func remove(at index: Int) { storage.remove(at: index) }
    public mutating func removeLast() { storage.removeLast() }
    public mutating func removeLast(_ k: Int) { storage.removeLast(k) }
    public mutating func removeFirst() { storage.removeFirst() }
    public mutating func removeFirst(_ k: Int) { storage.removeFirst(k) }
    public mutating func removeSubrange(_ bounds: Range<Int>) { storage.removeSubrange(bounds) }
    
    public func removing(at index: Int) -> Self {
        var newArray = storage
        newArray.remove(at: index)
        return SortedArray<Element>(quickLoad: newArray)
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        storage.removeAll(keepingCapacity: keepingCapacity)
    }
    
    public mutating func removeAll(where isExcluded: (Element) throws -> Bool) rethrows {
        try storage.removeAll(where: isExcluded)
    }
}

extension SortedArray: Codable where Element: Codable { }
extension SortedArray: ArrayBackedCollectionImpl { }

extension SortedArray: SortedArrayPublicInterface { }


private protocol SortedArrayPublicInterface {
    associatedtype Element: Comparable
    
    init()
    init(contentsOf elements: [Element])
    
    subscript(index: Int) -> Element { get }
    
    var values: [Element] { get }
    var count: Int { get }
    
    mutating func insert(_ element: Element)
    mutating func insert(contentsOf elements: [Element])
    func inserting(_ element: Element) -> Self
    func inserting(contentsOf elements: [Element]) -> Self

    mutating func merge(with array: SortedArray<Element>)
    func merging(with array: SortedArray<Element>) -> Self
    
    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> Result
    func reduce<Result>(into initialResult: inout Result, _ updateAccumulatingResult: (inout Result, Element) -> Void)
    
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self

    func forEach(_ body: (Element) throws -> Void) rethrows
   
    func map<T>(_ transform: (Element) throws -> T) rethrows -> [T]
    func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T]
}

