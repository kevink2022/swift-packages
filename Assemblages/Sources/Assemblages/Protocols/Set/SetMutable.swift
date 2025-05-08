//
//  SetInterfableCollection.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/4/25.
//

public protocol SetMutable: SetAddable, SetSubtractable, SetReadable { }

extension Set: SetMutable { }

