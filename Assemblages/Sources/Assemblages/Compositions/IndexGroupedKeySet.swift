//
//  IndexGroupedKeySet.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/6/25.
//

public struct IndexGroupedKeySet<Element: Identifiable, Index: Hashable>: SetMutable {

    public init(
        index: @escaping (Element) -> Index
    ) {
        self.storage = _IndexedKeySet(emptyIndex: {
            _GroupedIndex(
                index: index
                , emptyGroup: { _KeySet() }
            )
        })
    }
    
    internal typealias _KeySet = KeySet<Element>
    internal typealias _GroupedIndex = GroupedIndex<Element, Index, _KeySet>
    internal typealias _IndexedKeySet = IndexedKeySet<Element, _GroupedIndex>
    
    internal var storage: _IndexedKeySet
    
    public var count: Int { storage.count }
    public var isEmpty: Bool { storage.isEmpty }
    
    internal var keySet: KeySet<Element> { storage.keySet }
    public var dictionary: [Element.ID: Element] { keySet.dictionary }
    
    public subscript(id: Element.ID) -> Element? { storage.keySet[id] }
    public subscript(element: Element) -> Element? { storage.keySet[element.id] }
    public subscript(index: Index) -> KeySet<Element>? { storage.index[index] }
    
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
