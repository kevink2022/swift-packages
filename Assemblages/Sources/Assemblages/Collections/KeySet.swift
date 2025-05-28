//
//  KeySet.swift
//
//
//  Created by Kevin Kelly on 5/25/24.
//

import Foundation


/// The `KeySet` is just a dictionary that stores values based on their ID.
public struct KeySet<Element: Identifiable>: SetMutable {
    
    public init() {
        storage = [:]
    }
    
    public init(_ contentsOf: [Element]) {
        let elements = contentsOf
        storage = elements.reduce(into: [:]) { $0[$1.id] = $1 }
    }
    
    internal var storage: [Element.ID: Element] = [:]
    
    public var count: Int { storage.count }
    public var isEmpty: Bool { storage.isEmpty }
    
    public var dictionary: [Element.ID: Element] { storage }
    public var values: [Element] { Array(storage.values) }
    
    public subscript(id: Element.ID) -> Element? { storage[id] }
    public subscript(element: Element) -> Element? { storage[element.id] }
    
    @discardableResult
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        if let existingMember = storage[newMember.id] {
            return (false, existingMember)
        } else {
            storage[newMember.id] = newMember
            return (true, newMember)
        }
    }
    
    @discardableResult
    public mutating func update(with newMember: Element) -> Element? {
        let oldMember = storage[newMember.id]
        storage[newMember.id] = newMember
        return oldMember
    }
    
    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        let oldMember = storage[member.id]
        storage[member.id] = nil
        return oldMember
    }
    
    public func contains(_ element: Element) -> Bool {
        return storage[element.id] != nil
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
    
    public mutating func removeAll() {
        storage = [:]
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

extension KeySet: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Element
    
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension KeySet: ExpressibleByDictionaryLiteral {
    public typealias Key = Element.ID
    public typealias Value = Element
    
    public init(dictionaryLiteral elements: (Element.ID, Element)...) {
        self.init()
        for (id, element) in elements {
            storage[id] = element
        }
    }
}

extension KeySet: ArrayReadableImpl {
    var readableArray: [Element] { values }
}
