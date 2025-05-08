//
//  GroupedIn.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/9/25.
//

public struct GroupedIndex<Element, Index: Hashable, Group: SetMutable>: IndexableCollection where Group.Element == Element {
    
    public init(
        index: @escaping (Element) -> Index
        , emptyGroup: @escaping () -> Group
    ) {
        self.index = index
        self.groupFactory = emptyGroup
        self.storage = [:]
    }
    
    internal var storage: [Index: Group]
    internal let index: (Element) -> Index
    internal let groupFactory: () -> Group
    
    public var isEmpty: Bool { storage.isEmpty }
    public var count: Int { storage.values.reduce(0) { partialResult, group in partialResult + group.count } }
    
    public subscript(index: Index) -> Group? { storage[index] }
    
    public func contains(_ member: Element) -> Bool {
        let existingSet = storage[index(member)]
        return existingSet?.contains(member) ?? false
    }
    
    public mutating func insert(_ element: Element) {
        let elementIndex = index(element)
        
        if let existingSet = storage[elementIndex] {
            storage[elementIndex] = existingSet.inserting(element)
        } else {
            storage[elementIndex] = groupFactory().inserting(element)
        }
    }
    
    public mutating func remove(_ element: Element) {
        let elementIndex = index(element)
        
        if let existingSet = storage[elementIndex] {
            let newSet = existingSet.removing(element)
            storage[elementIndex] = newSet.isEmpty ? nil : newSet
        }
    }
    
    @discardableResult
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let elementIndex = index(newMember)
        let existingSet = storage[elementIndex]
        
        var newSet = existingSet ?? groupFactory()
        let result = newSet.insert(newMember)
        
        storage[elementIndex] = newSet
        return result
    }
    
    @discardableResult
    public mutating func update(with newMember: Element) -> Element? {
        let elementIndex = index(newMember)
        let existingSet = storage[elementIndex]
        
        var newSet = existingSet ?? groupFactory()
        let oldMember = newSet.update(with: newMember)
        
        storage[elementIndex] = newSet
        return oldMember
    }
    
    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        let elementIndex = index(member)
        
        guard let existingSet = storage[elementIndex] else { return nil }
        var newSet = existingSet
        
        guard let oldMember = newSet.remove(member) else { return nil }
        storage[elementIndex] = newSet.isEmpty ? nil : newSet
        return oldMember
    }
}
