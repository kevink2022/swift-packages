//
//  KeySet.swift
//
//
//  Created by Kevin Kelly on 5/25/24.
//

import Foundation


/// The `KeySet` is just a dictionary that stores values based on their ID.
public struct KeySet<Element: Identifiable> {
    
    public init() {
        storage = [:]
    }
    
    private var storage: [Element.ID: Element] = [:]
    
    public var count: Int { storage.count }
    
    public var values: [Element] {
        return Array(storage.values)
    }
    
    public subscript(id: Element.ID) -> Element? {
        return storage[id]
    }
    
    public subscript(element: Element) -> Element? {
        return storage[element.id]
    }
    
    public mutating func insert(_ element: Element) {
        storage[element.id] = element
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
    
    public func inserting(contentsOf elements: [Element]) -> Self {
        var newSet = self
        elements.forEach { element in
            newSet.insert(element)
        }
        return newSet
    }
    
    public mutating func remove(_ element: Element) {
        storage[element.id] = nil
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
        return storage[element.id] != nil
    }
    
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> Result {
        return storage.values.reduce(initialResult, nextPartialResult)
    }
    
    public func reduce<Result>(into initialResult: inout Result, _ updateAccumulatingResult: (inout Result, Element) -> Void) {
        for element in storage.values {
            updateAccumulatingResult(&initialResult, element)
        }
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
        var newSet = Self<Element>()
        for element in storage.values {
            if try isIncluded(element) {
                newSet.storage[element.id] = element
            }
        }
        return newSet
    }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try storage.values.forEach(body)
    }
    
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        try storage.values.map(transform)
    }
    
    public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
        try storage.values.compactMap(transform)
    }
}

extension KeySet: Codable where Element: Codable, Element.ID: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(storage, forKey: .storage)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        storage = try container.decode([Element.ID: Element].self, forKey: .storage)
    }

    private enum CodingKeys: String, CodingKey {
        case storage
    }
}

extension KeySet: KeySetPublicInterface { }
private protocol KeySetPublicInterface {
    associatedtype Element: Identifiable
    
    var values: [Element] { get }
    var count: Int { get }
    
    mutating func insert(_ element: Element)
    mutating func insert(contentsOf elements: [Element])
    func inserting(_ element: Element) -> Self
    func inserting(contentsOf elements: [Element]) -> Self
    
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
