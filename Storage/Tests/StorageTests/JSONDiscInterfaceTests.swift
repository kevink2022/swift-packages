import XCTest
@testable import Storage

final class JSONDiscInterfaceTests: DiscInterfaceTests {
    
    override func initSut(namespace: String? = nil) -> DiscInterface<String> {
        return JSONDiscInterface<String>(namespace: namespace)
    }
    
    override func wipeStorage() async {
        let fileManager = FileManager.default
        let rootDirectory = URL.applicationSupportDirectory.appending(path: "JSON_storage")
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: rootDirectory, includingPropertiesForKeys: nil, options: [])
            
            let testDirs = contents.filter { $0.lastPathComponent.hasPrefix("test") && $0.hasDirectoryPath }
            
            for directory in testDirs {
                try fileManager.removeItem(at: directory)
            }
        } catch {
            print("Failed to delete test directories: \(error)")
        }
    }
}
