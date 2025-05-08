//
//  IndexedKeySet.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/10/25.
//

public struct IndexedKeySet<Element: Identifiable, Index: IndexableCollection>: SetMutable where Index.Element == Element {
    
    public init(
        emptyIndex: @escaping () -> Index
    ) {
        let indexFactory = emptyIndex
        
        self.keySet = KeySet<Element>()
        self.index = indexFactory()
    }
    
    public var keySet: KeySet<Element>
    public var index: Index
    
    public var count: Int { keySet.count }
    public var isEmpty: Bool { keySet.isEmpty }
    
    public subscript(id: Element.ID) -> Element? { keySet[id] }
    public subscript(element: Element) -> Element? { keySet[element.id] }
    
    public func contains(_ member: Element) -> Bool { keySet.contains(member) }
    
    @discardableResult
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        
        if let oldMember = keySet[newMember] {
            return (false, oldMember)
        } else {
            keySet.insert(newMember)
            index.insert(newMember)
            return (true, newMember)
        }
    }
    
    @discardableResult
    public mutating func update(with newMember: Element) -> Element? {
        let oldMember = keySet[newMember]
        if let oldMember = oldMember { index.remove(oldMember) }
        keySet.update(with: newMember)
        index.update(with: newMember)
        return oldMember
    }
    
    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        guard let oldMember = keySet[member] else { return nil }
        keySet.remove(member)
        index.remove(member)
        return oldMember
    }
}

extension IndexedKeySet: ArrayReadableImpl {
    public var readableArray: [Element] {
        get { keySet.values }
    }
}
