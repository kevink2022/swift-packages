//
//  File.swift
//  
//
//  Created by Kevin Kelly on 11/24/24.
//

public protocol ArrayBackedCollection {
    associatedtype Element
    
    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> Result
    func reduce<Result>(into initialResult: inout Result, _ updateAccumulatingResult: (inout Result, Element) -> Void)
    
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self
    
    func forEach(_ body: (Element) throws -> Void) rethrows
    
    func map<T>(_ transform: (Element) throws -> T) rethrows -> [T]
    
    func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T]
    
    mutating func remove(at index: Int)
    mutating func removeLast()
    mutating func removeLast(_ k: Int)
    mutating func removeFirst()
    mutating func removeFirst(_ k: Int)
    mutating func removeSubrange(_ bounds: Range<Int>)
    mutating func removeAll()
}

internal protocol ArrayBackedCollectionImpl: ArrayBackedCollection {
    associatedtype Element
    var storage: [Element] { get set }
}

extension ArrayBackedCollectionImpl  {
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> Result {
        return storage.reduce(initialResult, nextPartialResult)
    }
    
    public func reduce<Result>(into initialResult: inout Result, _ updateAccumulatingResult: (inout Result, Element) -> Void) {
        for element in storage {
            updateAccumulatingResult(&initialResult, element)
        }
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
        var newSet = self
        newSet.storage = []
        for element in storage {
            if try isIncluded(element) {
                newSet.storage.append(element)
            }
        }
        return newSet
    }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try storage.forEach(body)
    }
    
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        try storage.map(transform)
    }
    
    public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
        try storage.compactMap(transform)
    }
    
    public mutating func remove(at index: Int) { storage.remove(at: index) }
    public mutating func removeLast() { storage.removeLast() }
    public mutating func removeLast(_ k: Int) { storage.removeLast(k) }
    public mutating func removeFirst() { storage.removeFirst() }
    public mutating func removeFirst(_ k: Int) { storage.removeFirst(k) }
    public mutating func removeSubrange(_ bounds: Range<Int>) { storage.removeSubrange(bounds) }
    public mutating func removeAll() { storage = [] }
}

