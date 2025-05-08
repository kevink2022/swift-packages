//
//  ArrayMutable.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/10/25.
//

public protocol ArrayMutable: ArrayAddable, ArraySubtractable, ArrayReadable { }

extension Array: ArrayMutable { }

internal protocol ArrayMutableImpl: ArrayMutable, ArrayAddableImpl, ArraySubtractableImpl {
    var mutableArray: [Element] { get set }
}

extension ArrayMutableImpl {
    var subtractableArray: [Element] { mutableArray }
    var addableArray: [Element] { mutableArray }
    var readableArray: [Element] { mutableArray }
}
