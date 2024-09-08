import XCTest
@testable import Storage

final class SimpleStoreTests: XCTestCase {
    
    func initSut(key: String, cached: Bool, namespace: String? = nil) -> SimpleStore<String> {
        return SimpleStore<String>(key: key, cached: cached, namespace: namespace, inMemory: true)
    }
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let fileManager = FileManager()
    
    let namespace = "test_namespace"
    let namespaceA = "test_namespaceA"
    let namespaceB = "test_namespaceB"
    let namespaceC = "test_namespaceC"
    let namespaceD = "test_namespaceD"
    
    func test_saveAndLoad() async throws {
        let value = "value_1"
        let key = "key_1"
        
        do {
            let sut = initSut(key: key, cached: false)
            
            try await sut.save(value)
            let loaded = try await sut.load()
            XCTAssertEqual(value, loaded)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        do {
            let sut = initSut(key: key, cached: true)
            
            try await sut.save(value)
            let loaded = try await sut.load()
            XCTAssertEqual(value, loaded)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_saveOverwriteLoad() async throws {
        let value = "value_2"
        let overwriteValue = "overwrite_2"
        let key = "key_2"
        
        do {
            let sut = initSut(key: key, cached: false)
            
            try await sut.save(value)
            let loaded = try await sut.load()
            XCTAssertEqual(value, loaded)

            try await sut.save(overwriteValue)
            let overwriteLoaded = try await sut.load()
            XCTAssertEqual(overwriteValue, overwriteLoaded)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        do {
            let sut = initSut(key: key, cached: true)
            
            try await sut.save(value)
            let loaded = try await sut.load()
            XCTAssertEqual(value, loaded)

            try await sut.save(overwriteValue)
            let overwriteLoaded = try await sut.load()
            XCTAssertEqual(overwriteValue, overwriteLoaded)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_saveReinitLoad() async throws {
        let value = "value_3"
        let key = "key_3"
        
        do {
            let sut = initSut(key: key, cached: false)
            try await sut.save(value)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        do {
            let sut = initSut(key: key, cached: false)
            let loaded = try await sut.load()
            XCTAssertEqual(value, loaded)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_namespaces() async throws {
        let valueA = "value_4A"
        let valueB = "value_4B"
        let key = "key_4"

        do {
            let sutA = initSut(key: key, cached: false, namespace: namespaceA)
            let sutB = initSut(key: key, cached: false, namespace: namespaceB)
            
            try await sutA.save(valueA)
            
            let loadA1 = try await sutA.load()
            let loadB1 = try await sutB.load()
            XCTAssertEqual(valueA, loadA1)
            XCTAssertEqual(nil, loadB1)

            try await sutB.save(valueB)
            
            let loadA2 = try await sutA.load()
            let loadB2 = try await sutB.load()
            XCTAssertEqual(valueA, loadA2)
            XCTAssertEqual(valueB, loadB2)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        do {
            let sutA = initSut(key: key, cached: true, namespace: namespaceC)
            let sutB = initSut(key: key, cached: true, namespace: namespaceD)
            
            try await sutA.save(valueA)
            
            let loadA1 = try await sutA.load()
            let loadB1 = try await sutB.load()
            XCTAssertEqual(valueA, loadA1)
            XCTAssertEqual(nil, loadB1)

            try await sutB.save(valueB)
            
            let loadA2 = try await sutA.load()
            let loadB2 = try await sutB.load()
            XCTAssertEqual(valueA, loadA2)
            XCTAssertEqual(valueB, loadB2)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_delete() async throws {
        let value = "value_5"
        let key = "key_5"
        
        do {
            let sut = initSut(key: key, cached: false, namespace: namespace)
            try await sut.save(value)
            let loaded = try await sut.load()
            XCTAssertEqual(value, loaded)

            try await sut.delete()
            let deleteLoaded = try await sut.load()
            XCTAssertEqual(nil, deleteLoaded)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        do {
            let sut = initSut(key: key, cached: true, namespace: namespace)
            try await sut.save(value)
            let loaded = try await sut.load()
            XCTAssertEqual(value, loaded)

            try await sut.delete()
            let deleteLoaded = try await sut.load()
            XCTAssertEqual(nil, deleteLoaded)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_exportData() async throws {
        let value = "value_6"
        let key = "key_6"
        
        let export_dir = "SimpleStore_Test_Export/"
        
        let export_root = URL
            .applicationSupportDirectory
            .appending(path: export_dir)
        
        let expected_export_url = URL
            .applicationSupportDirectory
            .appending(path: export_dir)
            .appending(path: namespace)
            .appending(path: "\(key)_\(String(describing: String.self)).json")
        
        do {
            let sut = initSut(key: key, cached: false, namespace: namespace)

            try await sut.exportData(to: export_root)
            XCTFail("Expected Error")
        } catch {
            guard let error = error as? DiscInterfaceError else { XCTFail("Expected DiscInterface Error"); return }
            XCTAssertEqual(error, DiscInterfaceError.noDataToExport)
        }

        do {
            let sut = initSut(key: key, cached: false, namespace: namespace)
            try await sut.save(value)

            try await sut.exportData(to: export_root)
            
            let exported_data = try Data(contentsOf: expected_export_url)
            let exported_value = try decoder.decode(String.self, from: exported_data)
            
            XCTAssertEqual(exported_value, value)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        do {
            let sut = initSut(key: key, cached: false, namespace: namespace)
            try await sut.save(value)

            try await sut.exportData(to: expected_export_url) // File URL
            XCTFail("Expected Error")
        } catch {
            guard let error = error as? DiscInterfaceError else { XCTFail("Expected DiscInterface Error"); return }
            XCTAssertEqual(error, DiscInterfaceError.attemptToExportToFile)
        }
        
        do {
            try fileManager.removeItem(at: expected_export_url)
        } catch {
            XCTFail("Teardown Error: \(error.localizedDescription)")
        }
    }
    
    func test_importData() async throws {
        let value = "value_7"
        let key = "key_7"
        
        let import_dir = "SimpleStore_Test_Import/"
        
        let expected_import_url = URL
            .applicationSupportDirectory
            .appending(path: import_dir)
            .appending(path: namespace)
            .appending(path: "\(key)_\(String(describing: String.self)).json")
        
        do {
            let data_to_import = try encoder.encode(value)
            try data_to_import.write(to: expected_import_url)
            guard fileManager.fileExists(atPath: expected_import_url.path) else { XCTFail("Setup Error"); return }
            
            let sut = initSut(key: key, cached: false, namespace: namespace)
            try await sut.importData(from: expected_import_url)
            
            let imported_value = try await sut.load()
            
            XCTAssertEqual(imported_value, value)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        do {
            let sut = initSut(key: key, cached: false, namespace: namespace)

            try await sut.importData(from: URL.applicationSupportDirectory) // Dir URL
            XCTFail("Expected Error")
        } catch {
            guard let error = error as? DiscInterfaceError else { XCTFail("Expected DiscInterface Error"); return }
            XCTAssertEqual(error, DiscInterfaceError.attemptToImportFromDir)
        }
        
        do {
            try fileManager.removeItem(at: expected_import_url)
        } catch {
            XCTFail("Teardown Error: \(error.localizedDescription)")
        }
    }
}
