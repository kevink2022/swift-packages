//
//  Key.swift
//  Domain
//
//  Created by Kevin Kelly on 2/23/25.
//

import Foundation

/// The Identifier for any record or object in hede that needs to be identifiable.
public struct Key: Identifiable, Codable, Equatable, Hashable, Nullable {
    public let id: UUID
    
    public static func new() -> Self { Key(id: UUID()) }
    
    /// A non-nil key that is passed to represent a nil date for setting optional parameters to nil.
    ///
    /// This should *never* be stored, any optional keys should be stored as nil. This is only for setting keys to nil when they are opitionally passed.
    /// Storing this key to represent a nil key will break, as a new one is generated on each launch of the app.
    public static let null = Key(id: UUID())
}
