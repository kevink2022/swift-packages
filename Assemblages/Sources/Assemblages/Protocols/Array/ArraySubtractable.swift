//
//  File.swift
//  
//
//  Created by Kevin Kelly on 11/24/24.
//

/// Collection can be mutated to remove objects like an array..
public protocol ArraySubtractable: ArrayReadable {
    associatedtype Element
    
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self
    
    @discardableResult mutating func remove(at index: Int) -> Element
    @discardableResult mutating func removeLast() -> Self.Element
    mutating func removeLast(_ k: Int)
    @discardableResult mutating func removeFirst() -> Self.Element
    mutating func removeFirst(_ k: Int)
    mutating func removeSubrange(_ bounds: Range<Int>)
}

internal protocol ArraySubtractableImpl: ArraySubtractable & ArrayReadableImpl {
    associatedtype Element
    var subtractableArray: [Element] { get set }
}

extension ArraySubtractableImpl {
    internal var readableArray: [Element] { subtractableArray }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
        var newSet = self
        newSet.subtractableArray = []
        for element in subtractableArray {
            if try isIncluded(element) {
                newSet.subtractableArray.append(element)
            }
        }
        return newSet
    }
    
    public mutating func remove(at index: Int) -> Element { subtractableArray.remove(at: index) }
    public mutating func removeLast() -> Self.Element { subtractableArray.removeLast() }
    public mutating func removeLast(_ k: Int) { subtractableArray.removeLast(k) }
    public mutating func removeFirst() -> Self.Element { subtractableArray.removeFirst() }
    public mutating func removeFirst(_ k: Int) { subtractableArray.removeFirst(k) }
    public mutating func removeSubrange(_ bounds: Range<Int>) { subtractableArray.removeSubrange(bounds) }
}


