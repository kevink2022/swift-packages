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
    ) {
        self.storage = SortedSetIndex(
            lessThan: <
            , equalTo: ==
            , sortOption: .any
            , contentsOf: contentsOf
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
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let elements = try container.decode([Element].self)
        self.init(elements.sorted())
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(values)
    }
}

extension SortedSet: Equatable where Element: Equatable {
    public static func == (lhs: SortedSet, rhs: SortedSet) -> Bool {
        lhs.storage.storage == rhs.storage.storage
    }
}
