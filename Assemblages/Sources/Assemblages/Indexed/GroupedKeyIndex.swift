//
//  GroupedKeyIndex.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/6/25.
//

//public struct GroupedKeyIndex<Element: Identifiable, Index: Hashable>: SetInterfableCollection {
//    
//    public init(
//        index: @escaping (Element) -> Index
//    ) {
//        self.index = index
//        self.storage = [:]
//    }
//    
//    internal var storage: [Index: KeySet<Element>]
//    internal let index: (Element) -> Index
//    
//    public subscript(index: Index) -> KeySet<Element>? { storage[index] }
//    
//    public var isEmpty: Bool { storage.isEmpty }
//
//    public mutating func insert(_ element: Element) {
//        let elementIndex = index(element)
//        
//        if let existingSet = storage[elementIndex] {
//            storage[elementIndex] = existingSet.inserting(element)
//        } else {
//            storage[elementIndex] = KeySet<Element>().inserting(element)
//        }
//    }
//    
//    public mutating func remove(_ element: Element) {
//        let elementIndex = index(element)
//        
//        if let existingSet = storage[elementIndex] {
//            let newSet = existingSet.removing(element)
//            storage[elementIndex] = newSet.isEmpty ? nil : newSet
//        }
//    }
//}

public struct GroupedKeyIndex<Element: Identifiable, Index: Hashable>: IndexableCollection {
    
    public init(
        index: @escaping (Element) -> Index
    ) {
        self.storage = GroupedIndex<Element, Index, KeySet>(
            index: index
            , emptyGroup: { KeySet<Element>() }
        )
    }
    
    internal var storage: GroupedIndex<Element, Index, KeySet<Element>>
    
    public var isEmpty: Bool { storage.isEmpty }
    public var count: Int { storage.count }
    
    public subscript(index: Index) -> KeySet<Element>? { storage[index] }
    
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
