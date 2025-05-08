//
//  ArrayReadableCollection.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/9/25.
//

/// Object can be read like an array
public protocol ArrayReadable {
    associatedtype Element
    
    func reduce<Result>(
        _ initialResult: Result
        , _ nextPartialResult: (Result, Self.Element) throws -> Result
    ) rethrows -> Result
    
    func reduce<Result>(
        into initialResult: Result
        , _ updateAccumulatingResult: (inout Result, Self.Element) throws -> ()
    ) rethrows -> Result

    func forEach(_ body: (Element) throws -> Void) rethrows
    
    func map<T>(_ transform: (Element) throws -> T) rethrows -> [T]
    
    func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T]
}

/// Collection can be read as an array, but not mutated through the array alone.
internal protocol ArrayReadableImpl: ArrayReadable {
    associatedtype Element
    var readableArray: [Element] { get }
}

extension ArrayReadableImpl  {
    public func reduce<Result>(
        _ initialResult: Result
        , _ nextPartialResult: (Result, Self.Element) throws -> Result
    ) rethrows -> Result {
        return try readableArray.reduce(initialResult, nextPartialResult)
    }
    
    public func reduce<Result>(
        into initialResult: Result
        , _ updateAccumulatingResult: (inout Result, Self.Element) throws -> ()
    ) rethrows -> Result {
        var result = initialResult
        for element in readableArray {
            try updateAccumulatingResult(&result, element)
        }
        return result
    }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try readableArray.forEach(body)
    }
    
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        try readableArray.map(transform)
    }
    
    public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
        try readableArray.compactMap(transform)
    }
}
