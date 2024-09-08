//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/20/24.
//

import Foundation

/// The Counted Set maintains a count of the number of times an item has been inserted or removed.
/// An item exists in the set if it has been inserted more then it has been removed.
struct CountedSet<Element: Hashable> {
    
    public init() {
        storage = [:]
    }
    
    private var storage: [Element: Int]
    
    public var count: Int { storage.count }
    
    public var values: [Element] {
        return Array(storage.keys)
    }
    
    public var counts: [Element: Int] { storage }
    
    public mutating func insert(_ element: Element) {
        if let count = storage[element] {
            storage[element] = count + 1
        } else {
            storage[element] = 1
        }
    }
    
    public func inserting(_ element: Element) -> Self {
        var newSet = self
        newSet.insert(element)
        return newSet
    }
    
    public mutating func insert(contentsOf elements: [Element]) {
        elements.forEach { element in
            self.insert(element)
        }
    }
    
    public mutating func insert(contentsOf elements: Set<Element>) {
        elements.forEach { element in
            self.insert(element)
        }
    }
    
    public func inserting(contentsOf elements: [Element]) -> Self {
        var newSet = self
        elements.forEach { element in
            newSet.insert(element)
        }
        return newSet
    }
    
    public func inserting(contentsOf elements: Set<Element>) -> Self {
        var newSet = self
        elements.forEach { element in
            newSet.insert(element)
        }
        return newSet
    }
    
    public mutating func remove(_ element: Element) {
        if let count = storage[element] {
            if count <= 1 { storage[element] = nil }
            else { storage[element] = count - 1 }
        }
    }
    
    public func removing(_ element: Element) -> Self {
        var newSet = self
        newSet.remove(element)
        return newSet
    }
    
    public mutating func remove(contentsOf elements: [Element]) {
        elements.forEach { element in
            self.remove(element)
        }
    }
    
    public func removing(contentsOf elements: [Element]) -> Self {
        var newSet = self
        elements.forEach { element in
            newSet.remove(element)
        }
        return newSet
    }
    
    public func contains(_ element: Element) -> Bool {
        return storage[element] != nil
    }
    
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> Result {
        return storage.keys.reduce(initialResult, nextPartialResult)
    }
    
    public func reduce<Result>(into initialResult: inout Result, _ updateAccumulatingResult: (inout Result, Element) -> Void) {
        for element in storage.keys {
            updateAccumulatingResult(&initialResult, element)
        }
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
        var newSet = Self<Element>()
        for element in storage.keys {
            if try isIncluded(element) {
                newSet.storage[element] = storage[element]
            }
        }
        return newSet
    }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try storage.keys.forEach(body)
    }
    
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        try storage.keys.map(transform)
    }
    
    public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
        try storage.keys.compactMap(transform)
    }
}

extension CountedSet: CountedSetPublicInterface { }
private protocol CountedSetPublicInterface {
    associatedtype Element: Hashable
    
    var values: [Element] { get }
    var counts: [Element: Int] { get }
    var count: Int { get }
    
    mutating func insert(_ element: Element)
    mutating func insert(contentsOf elements: [Element])
    mutating func insert(contentsOf elements: Set<Element>)
    func inserting(_ element: Element) -> Self
    func inserting(contentsOf elements: [Element]) -> Self
    func inserting(contentsOf elements: Set<Element>) -> Self
    
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
