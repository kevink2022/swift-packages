//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/23/24.
//

import Foundation

public typealias Bytes = Int64

public class DiscInterface<Model: Codable> {
    
    func save(_ model: Model, to key: String) async throws {
        throw DiscInterfaceError.mustOverride
    }
    func load(from key: String) async throws -> Model? {
        throw DiscInterfaceError.mustOverride
    }
    func delete(_ key: String) async throws {
        throw DiscInterfaceError.mustOverride
    }
    func size(_ key: String) async throws -> Bytes {
        throw DiscInterfaceError.mustOverride
    }
    func allocatedSize(_ key: String) async throws -> Bytes {
        throw DiscInterfaceError.mustOverride
    }
    func sizeAndAllocatedSize(_ key: String) async throws -> (Bytes, Bytes) {
        throw DiscInterfaceError.mustOverride
    }
}

public enum DiscInterfaceError: LocalizedError {
    case mustOverride
    case noDataToExport
    case noDataToImport
    case attemptToExportToFile
    case attemptToImportFromDir
    
    public var errorDescription: String? {
        switch self {
        case .mustOverride: "This function must be overridden to be used."
        case .noDataToExport: "There is no data to export."
        case .noDataToImport: "There is no data to import."
        case .attemptToExportToFile: "Attempted to export to a file instead of a directory."
        case .attemptToImportFromDir: "Attempted to import from a directory instead of a file."
        }
    }
}

extension Int64 {
    public var fileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .decimal
        formatter.formattingContext = .standalone
        formatter.allowsNonnumericFormatting = false
        return formatter.string(fromByteCount: self)
    }
}

extension URL {
    public func fileSize() throws -> Bytes {
        let resourceValues = try self.resourceValues(forKeys: [
            .isRegularFileKey,
            .fileSizeKey,
            .totalFileSizeKey,
        ])

        guard resourceValues.isRegularFile ?? false else { return 0 }
        return Int64(resourceValues.totalFileSize ?? resourceValues.fileSize ?? 0)
    }
    
    public func fileAllocatedSize() throws -> Bytes {
        let resourceValues = try self.resourceValues(forKeys: [
            .isRegularFileKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey,
        ])

        guard resourceValues.isRegularFile ?? false else { return 0 }
        return Int64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }
    
    public func fileSizeAndAllocatedSize() throws -> (Bytes, Bytes) {
        return (try self.fileSize(), try self.fileAllocatedSize())
    }
}
