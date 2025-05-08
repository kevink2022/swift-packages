//
//  GroupedIndex.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/4/25.
//

import Foundation

public struct GroupedSetIndex<Element: Hashable, Index: Hashable>: IndexableCollection {
 
    public init(
        index: @escaping (Element) -> Index
    ) {
        self.storage = GroupedIndex<Element, Index, Set>(
            index: index
            , emptyGroup: { Set<Element>() }
        )
    }

    internal var storage: GroupedIndex<Element, Index, Set<Element>>


    public var isEmpty: Bool { storage.isEmpty }
    public var count: Int { storage.count }

    public subscript(index: Index) -> Set<Element>? { storage[index] }
    
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

