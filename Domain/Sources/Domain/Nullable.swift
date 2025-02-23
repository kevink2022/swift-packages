//
//  Nullable.swift
//  Domain
//
//  Created by Kevin Kelly on 2/16/25.
//

import Foundation

/// Passable as explicitly null when optional means 'ignore.'
public protocol Nullable: Equatable {
    /// The representation of a 'null' object.
    ///
    /// This object should never be stored permanently, as it may change between sessions.
    static var null: Self { get }
}

extension Nullable {
    /// Turn a null into a nil.
    public func nulled() -> Self? {
        return self == .null ? nil : self
    }
}

extension Optional where Wrapped: Nullable {
    /// Compare a newer nullable to an original value.
    ///
    /// If the nullable is null, returns nil. If the nullable is nil, returns the original. Otherwise, returns itself.
    public func null(or original: Wrapped?) -> Wrapped? {
        switch self {
        case .some(let value) where value == Wrapped.null:
            return nil
        case .none:
            return original
        case .some(let value):
            return value
        }
    }
}

extension Date: Nullable {
    public static let null = Date(timeIntervalSince1970: 0)
}

extension String: Nullable {
    public static let null = ""
}

extension Array: Nullable where Element: Equatable {
    public static var null: Array<Element> {
        return []
    }
}
