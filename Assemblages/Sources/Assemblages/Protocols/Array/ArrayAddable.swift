//
//  ArrayAddable.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/10/25.
//

public protocol ArrayAddable: ArrayReadable {
    associatedtype Element
    
    mutating func append(_ newElement: Element)
}

internal protocol ArrayAddableImpl: ArrayAddable & ArrayReadableImpl {
    associatedtype Element
    var addableArray: [Element] { get set }
}

extension ArrayAddableImpl {
    public mutating func append(_ newElement: Element) { addableArray.append(newElement) }
}
