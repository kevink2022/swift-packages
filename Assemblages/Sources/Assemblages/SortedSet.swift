//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/20/24.
//

import Foundation


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

extension SortedSet where Element: Hashable {
    public init(set: Set<Element>) {
        self.storage = set.sorted()
    }
}

extension SortedSet: Codable where Element: Codable { }
extension SortedSet: ArrayBackedCollectionImpl {
    public typealias Element = Element
}

extension SortedSet: SortedSetPublicInterface { }
private protocol SortedSetPublicInterface {
    associatedtype Element: Comparable
    
    init()
    init(contentsOf elements: [Element])
    
    subscript(index: Int) -> Element { get }
    subscript(element: Element) -> Element? { get }
    
    var values: [Element] { get }
    var count: Int { get }
    
    mutating func insert(_ element: Element)
    mutating func insert(contentsOf elements: [Element])
    func inserting(_ element: Element) -> Self
    func inserting(contentsOf elements: [Element]) -> Self

    mutating func union(_ set: SortedSet<Element>)
    func unioning(_ set: SortedSet<Element>) -> Self

    mutating func remove(_ element: Element)
    mutating func remove(contentsOf elements: [Element])
    func removing(_ element: Element) -> Self
    func removing(contentsOf elements: [Element]) -> Self

    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> Result
    func reduce<Result>(into initialResult: inout Result, _ updateAccumulatingResult: (inout Result, Element) -> Void)
    
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self

    func forEach(_ body: (Element) throws -> Void) rethrows
   
    func map<T>(_ transform: (Element) throws -> T) rethrows -> [T]
    func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T]
}
