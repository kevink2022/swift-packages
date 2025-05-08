//
//  File.swift
//  
//
//  Created by Kevin Kelly on 11/13/24.
//

import Foundation

/// The `IndexSortedKeySet` is a `KeySet` that tracks sorting in an external array.
///
/// Items that are equal on the sort index, but have different IDs, will both be contained in the set, being placed last in the subset of existing equal sorts.
public struct IndexSortedKeySet<Element: Identifiable>: SetMutable {
    
    public init(
        lessThan: @escaping (Element, Element) -> Bool
        , set: KeySet<Element> = KeySet<Element>()
        , sortOption: DuplicateInsertSortingOption = .any
    ) {
        self.keyed = set
        self.sorted = SortedSetIndex(
            lessThan: lessThan
            , equalTo: { lhs, rhs in lhs.id == rhs.id }
            , sortOption: sortOption
            , contentsOf: set.values
        )
    }
    
    internal var keyed: KeySet<Element>
    internal var sorted: SortedSetIndex<Element>
    
    public var count: Int { sorted.count }
    public var dictionary: [Element.ID: Element] { keyed.dictionary }
    public var values: [Element] { sorted.values }
    public var isEmpty: Bool { keyed.isEmpty }
    
    public subscript(id: Element.ID) -> Element? { keyed[id] }
    public subscript(element: Element) -> Element? { keyed[element.id] }
    
    @discardableResult
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        if let oldMember = keyed[newMember] {
            return (false, oldMember)
        } else {
            keyed.insert(newMember)
            sorted.insert(newMember)
            return (true, newMember)
        }
    }
    
    @discardableResult
    public mutating func update(with newMember: Element) -> Element? {
        if let oldMember = keyed[newMember] {
            sorted.remove(oldMember) // Need to ensure old member is remove incase sort index changed.
            keyed.update(with: newMember)
            sorted.update(with: newMember)
            return oldMember
        } else {
            keyed.update(with: newMember)
            sorted.update(with: newMember)
            return nil
        }
    }
    
    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        guard let oldMember = keyed[member] else { return nil }
        keyed.remove(member)
        sorted.remove(member)
        return oldMember
    }
    
    public func contains(_ element: Element) -> Bool {
        return keyed[element.id] != nil
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
        var newSet = self
        newSet.keyed.storage = [:]
        newSet.sorted.storage = []
        for element in sorted.storage {
            if try isIncluded(element) {
                newSet.insert(element)
            }
        }
        return newSet
    }
}

extension IndexSortedKeySet: ArrayReadableImpl {
    public var readableArray: [Element] {
        get { sorted.storage }
    }
}
