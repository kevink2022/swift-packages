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
}

internal protocol ArrayBackedCollectionImpl: ArrayBackedCollection {
    associatedtype Element
    var storage: [Element] { get set }
    init()
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
        var newSet = Self()
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
}

