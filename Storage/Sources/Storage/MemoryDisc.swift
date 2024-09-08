//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/27/24.
//

import Foundation

internal final actor MemoryDisc {
    
    static let shared = MemoryDisc()
    private var storage: [String: [String: Codable]] = [:]

    public func save<Model: Codable>(_ model: Model, in namespace: String, to key: String) {
        var namespaceDictionary = storage[namespace] ?? [:]
        namespaceDictionary[key] = model
        storage[namespace] = namespaceDictionary
    }

    public func load<Model: Codable>(from namespace: String, key: String) -> Model? {
        storage[namespace]?[key] as? Model
    }
    
    public func delete(_ key: String, in namespace: String) {
        var namespaceDictionary = storage[namespace] ?? [:]
        namespaceDictionary[key] = nil
        storage[namespace] = namespaceDictionary
    }
    
    public func wipe() {
        storage = [:]
    }
}

public final class MemoryDiscInterface<Model: Codable>: DiscInterface<Model> {
    
    private let disc = MemoryDisc.shared
    private let namespace: String
    
    public init(
        namespace: String? = nil
    ) {
        self.namespace = namespace ?? ""
    }
    
    public override func save(_ model: Model, to key: String) async throws {
        await disc.save(model, in: namespace, to: key)
    }
    
    public override func load(from key: String) async throws -> Model? {
        return await disc.load(from: namespace, key: key)
    }
    
    public override func delete(_ key: String) async throws {
        await disc.delete(key, in: namespace)
    }
    
    public override func size(_ key: String) async throws -> Bytes {
        return 0
    }
    
    public override func allocatedSize(_ key: String) async throws -> Bytes {
        return 0
    }
    
    public override func sizeAndAllocatedSize(_ key: String) async throws -> (Bytes, Bytes) {
        return (0, 0)
    }
}
