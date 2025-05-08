//
//  GroupKeyIndexTests.swift
//  Assemblages
//
//  Created by Kevin Kelly on 4/6/25.
//

import XCTest
@testable import Assemblages

final class GroupedKeyIndexTests: XCTestCase {
        
    struct TestElement: Identifiable, Equatable {
        let id: UUID
        let name: String
        let category: String
        
        init(id: UUID = UUID(), name: String, category: String) {
            self.id = id
            self.name = name
            self.category = category
        }
    }
    
    
    func test_initialization() {
        let groupedIndex = GroupedKeyIndex<TestElement, String> { $0.category }
        
        XCTAssertEqual(groupedIndex.storage.storage.count, 0, "Storage should be empty on initialization")
    }
    
    func test_insertFirstElement() {
        var groupedIndex = GroupedKeyIndex<TestElement, String> { $0.category }
        let element = TestElement(name: "Item1", category: "A")
        
        groupedIndex.insert(element)
        
        XCTAssertEqual(groupedIndex.storage.storage.count, 1, "Storage should contain one index")
        XCTAssertEqual(groupedIndex["A"]?.count, 1, "KeySet at index 'A' should contain one element")
        XCTAssertEqual(groupedIndex["A"]?[element.id], element, "KeySet at index 'A' should contain the inserted element")
    }
    
    func test_insertMultipleElementsWithSameIndex() {
        var groupedIndex = GroupedKeyIndex<TestElement, String> { $0.category }
        let element1 = TestElement(name: "Item1", category: "A")
        let element2 = TestElement(name: "Item2", category: "A")
        
        groupedIndex.insert(element1)
        groupedIndex.insert(element2)
        
        XCTAssertEqual(groupedIndex.storage.storage.count, 1, "Storage should contain one index")
        XCTAssertEqual(groupedIndex["A"]?.count, 2, "KeySet at index 'A' should contain two elements")
        XCTAssertEqual(groupedIndex["A"]?[element1.id], element1, "KeySet at index 'A' should contain element1")
        XCTAssertEqual(groupedIndex["A"]?[element2.id], element2, "KeySet at index 'A' should contain element2")
    }
    
    func test_insertMultipleElementsWithDifferentIndices() {
        var groupedIndex = GroupedKeyIndex<TestElement, String> { $0.category }
        let element1 = TestElement(name: "Item1", category: "A")
        let element2 = TestElement(name: "Item2", category: "B")
        
        groupedIndex.insert(element1)
        groupedIndex.insert(element2)
        
        XCTAssertEqual(groupedIndex.storage.storage.count, 2, "Storage should contain two indices")
        XCTAssertEqual(groupedIndex["A"]?.count, 1, "KeySet at index 'A' should contain one element")
        XCTAssertEqual(groupedIndex["B"]?.count, 1, "KeySet at index 'B' should contain one element")
        XCTAssertEqual(groupedIndex["A"]?[element1.id], element1, "KeySet at index 'A' should contain element1")
        XCTAssertEqual(groupedIndex["B"]?[element2.id], element2, "KeySet at index 'B' should contain element2")
    }
    
    func test_insertDuplicateElements() {
        var groupedIndex = GroupedKeyIndex<TestElement, String> { $0.category }
        let id = UUID()
        let element1 = TestElement(id: id, name: "Item1", category: "A")
        let element2 = TestElement(id: id, name: "Updated Item1", category: "A") // Same ID, different name
        
        groupedIndex.insert(element1)
        groupedIndex.insert(element2)
        
        XCTAssertEqual(groupedIndex.storage.storage.count, 1, "Storage should contain one index")
        XCTAssertEqual(groupedIndex["A"]?.count, 1, "KeySet at index 'A' should contain one element")
        XCTAssertEqual(groupedIndex["A"]?[id]?.name, "Item1", "Element should not be updated with the latest values")
    }
    
    func test_updateDuplicateElements() {
        var groupedIndex = GroupedKeyIndex<TestElement, String> { $0.category }
        let id = UUID()
        let element1 = TestElement(id: id, name: "Item1", category: "A")
        let element2 = TestElement(id: id, name: "Updated Item1", category: "A") // Same ID, different name
        
        groupedIndex.update(with: element1)
        groupedIndex.update(with: element2)
        
        XCTAssertEqual(groupedIndex.storage.storage.count, 1, "Storage should contain one index")
        XCTAssertEqual(groupedIndex["A"]?.count, 1, "KeySet at index 'A' should contain one element")
        XCTAssertEqual(groupedIndex["A"]?[id]?.name, "Updated Item1", "Element should be updated with the latest values")
    }
    
    func test_removeSingleElement() {
        var groupedIndex = GroupedKeyIndex<TestElement, String> { $0.category }
        let element = TestElement(name: "Item1", category: "A")
        
        groupedIndex.insert(element)
        groupedIndex.remove(element)
        
        XCTAssertNil(groupedIndex["A"], "KeySet at index 'A' should be nil or removed from storage")
        XCTAssertEqual(groupedIndex.storage.storage.count, 0, "Storage should be empty after removing the only element")
    }
    
    func test_removeOneOfMultipleElementsWithSameIndex() {
        var groupedIndex = GroupedKeyIndex<TestElement, String> { $0.category }
        let element1 = TestElement(name: "Item1", category: "A")
        let element2 = TestElement(name: "Item2", category: "A")
        
        groupedIndex.insert(element1)
        groupedIndex.insert(element2)
        groupedIndex.remove(element1)
        
        XCTAssertEqual(groupedIndex.storage.storage.count, 1, "Storage should still contain one index")
        XCTAssertEqual(groupedIndex["A"]?.count, 1, "KeySet at index 'A' should contain one element")
        XCTAssertEqual(groupedIndex["A"]?[element2.id], element2, "KeySet at index 'A' should contain element2")
        XCTAssertNil(groupedIndex["A"]?[element1.id], "KeySet at index 'A' should not contain element1")
    }
    
    func test_removeNonExistentElement() {
        var groupedIndex = GroupedKeyIndex<TestElement, String> { $0.category }
        let element1 = TestElement(name: "Item1", category: "A")
        let element2 = TestElement(name: "Item2", category: "A")
        
        groupedIndex.insert(element1)
        groupedIndex.remove(element2)
        
        XCTAssertEqual(groupedIndex.storage.storage.count, 1, "Storage should still contain one index")
        XCTAssertEqual(groupedIndex["A"]?.count, 1, "KeySet at index 'A' should still contain one element")
        XCTAssertEqual(groupedIndex["A"]?[element1.id], element1, "KeySet at index 'A' should still contain element1")
    }
    
    func test_subscriptForNonExistentIndex() {
        let groupedIndex = GroupedKeyIndex<TestElement, String> { $0.category }
        
        XCTAssertNil(groupedIndex["NonExistent"], "Subscript should return nil for non-existent index")
    }
    
    func test_removeLastElementInIndex() {
        var groupedIndex = GroupedKeyIndex<TestElement, String> { $0.category }
        let elementA = TestElement(name: "ItemA", category: "A")
        let elementB = TestElement(name: "ItemB", category: "B")
        
        groupedIndex.insert(elementA)
        groupedIndex.insert(elementB)
        groupedIndex.remove(elementB)
        
        XCTAssertEqual(groupedIndex.storage.storage.count, 1, "Storage should contain only one index")
        XCTAssertNil(groupedIndex["B"], "KeySet at index 'B' should be nil after removing its only element")
        XCTAssertNotNil(groupedIndex["A"], "KeySet at index 'A' should still exist")
    }
}
