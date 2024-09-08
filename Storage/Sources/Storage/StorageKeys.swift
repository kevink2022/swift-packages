//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/23/24.
//

import Foundation

public struct StorageKey {
    internal let namespace: String?
    internal let key: String
    internal let version: Int
    
    public init(
        namespace: String?
        , key: String
        , version: Int
    ) {
        self.namespace = namespace
        self.key = key
        self.version = version
    }
    
    internal var keyVersion: String {
        "\(key)-\(String(version))"
    }
}

extension SimpleStore {
    public convenience init(
        key: StorageKey
        , cached: Bool
        , inMemory: Bool = false
    ) {
        self.init(
            key: key.keyVersion
            , cached: cached
            , namespace: key.namespace
            , inMemory: inMemory
        )
    }
}

extension LogStore {
    public convenience init(
        key: StorageKey
        , cached: Bool
        , inMemory: Bool = false
    ) {
        self.init(
            key: key.keyVersion
            , cached: cached
            , namespace: key.namespace
            , inMemory: inMemory
        )
    }
}

extension Transactor {
    public convenience init(
        key: StorageKey
        , basePost: Post
        , inMemory: Bool = false
        , coreCommit: @escaping (TransactionData, Post) async -> (Post)
        , flatten: (([TransactionData]) -> TransactionData)? = nil
    ) {
        self.init(
            basePost: basePost
            , key: key.keyVersion
            , namespace: key.namespace
            , inMemory: inMemory
            , coreCommit: coreCommit
            , flatten: flatten
        )
    }
}

