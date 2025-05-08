////
////  GroupIndexTests.swift
////  Assemblages
////
////  Created by Kevin Kelly on 4/4/25.
////
//
//import XCTest
//@testable import Assemblages
//
//final class GroupedSetIndexTests: XCTestCase {
//        
//    private struct TestElement: Hashable {
//        let id: Int
//        let category: String
//    }
//        
//    func test_initialization() {
//        let groupedSet = GroupedSetIndex<TestElement, String> { $0.category }
//        
//        XCTAssertEqual(groupedSet.storage.count, 0, "Storage should be empty on initialization")
//    }
//    
//    func test_insertFirstElement() {
//        var groupedSet = GroupedSetIndex<TestElement, String> { $0.category }
//        let element = TestElement(id: 1, category: "A")
//        
//        groupedSet.insert(element)
//        
//        XCTAssertEqual(groupedSet.storage.count, 1, "Storage should contain one index")
//        XCTAssertEqual(groupedSet["A"]?.count, 1, "Set at index 'A' should contain one element")
//        XCTAssertTrue(groupedSet["A"]?.contains(element) ?? false, "Set at index 'A' should contain the inserted element")
//    }
//    
//    func tes_insertMultipleElementsWithSameIndex() {
//        var groupedSet = GroupedSetIndex<TestElement, String> { $0.category }
//        let element1 = TestElement(id: 1, category: "A")
//        let element2 = TestElement(id: 2, category: "A")
//        
//        groupedSet.insert(element1)
//        groupedSet.insert(element2)
//        
//        XCTAssertEqual(groupedSet.storage.count, 1, "Storage should contain one index")
//        XCTAssertEqual(groupedSet["A"]?.count, 2, "Set at index 'A' should contain two elements")
//        XCTAssertTrue(groupedSet["A"]?.contains(element1) ?? false, "Set at index 'A' should contain element1")
//        XCTAssertTrue(groupedSet["A"]?.contains(element2) ?? false, "Set at index 'A' should contain element2")
//    }
//    
//    func test_insertMultipleElementsWithDifferentIndices() {
//        var groupedSet = GroupedSetIndex<TestElement, String> { $0.category }
//        let element1 = TestElement(id: 1, category: "A")
//        let element2 = TestElement(id: 2, category: "B")
//        
//        groupedSet.insert(element1)
//        groupedSet.insert(element2)
//        
//        XCTAssertEqual(groupedSet.storage.count, 2, "Storage should contain two indices")
//        XCTAssertEqual(groupedSet["A"]?.count, 1, "Set at index 'A' should contain one element")
//        XCTAssertEqual(groupedSet["B"]?.count, 1, "Set at index 'B' should contain one element")
//        XCTAssertTrue(groupedSet["A"]?.contains(element1) ?? false, "Set at index 'A' should contain element1")
//        XCTAssertTrue(groupedSet["B"]?.contains(element2) ?? false, "Set at index 'B' should contain element2")
//    }
//    
//    func test_insertDuplicateElement() {
//        var groupedSet = GroupedSetIndex<TestElement, String> { $0.category }
//        let element = TestElement(id: 1, category: "A")
//        
//        groupedSet.insert(element)
//        groupedSet.insert(element) // Insert the same element again
//        
//        XCTAssertEqual(groupedSet.storage.count, 1, "Storage should contain one index")
//        XCTAssertEqual(groupedSet["A"]?.count, 1, "Set at index 'A' should still contain only one element (no duplicates)")
//    }
//    
//    func test_removeSingleElement() {
//        var groupedSet = GroupedSetIndex<TestElement, String> { $0.category }
//        let element = TestElement(id: 1, category: "A")
//        
//        groupedSet.insert(element)
//        groupedSet.remove(element)
//        
//        XCTAssertNil(groupedSet["A"], "Set at index 'A' should be nil or removed from storage")
//        XCTAssertEqual(groupedSet.storage.count, 0, "Storage should be empty after removing the only element")
//    }
//    
//    func test_removeOneOfMultipleElementsWithSameIndex() {
//        var groupedSet = GroupedSetIndex<TestElement, String> { $0.category }
//        let element1 = TestElement(id: 1, category: "A")
//        let element2 = TestElement(id: 2, category: "A")
//        
//        groupedSet.insert(element1)
//        groupedSet.insert(element2)
//        groupedSet.remove(element1)
//        
//        XCTAssertEqual(groupedSet.storage.count, 1, "Storage should still contain one index")
//        XCTAssertEqual(groupedSet["A"]?.count, 1, "Set at index 'A' should contain one element")
//        XCTAssertTrue(groupedSet["A"]?.contains(element2) ?? false, "Set at index 'A' should contain element2")
//        XCTAssertFalse(groupedSet["A"]?.contains(element1) ?? true, "Set at index 'A' should not contain element1")
//    }
//    
//    func test_removeNonExistentElement() {
//        var groupedSet = GroupedSetIndex<TestElement, String> { $0.category }
//        let element1 = TestElement(id: 1, category: "A")
//        let element2 = TestElement(id: 2, category: "A")
//        
//        groupedSet.insert(element1)
//        groupedSet.remove(element2)
//        
//        XCTAssertEqual(groupedSet.storage.count, 1, "Storage should still contain one index")
//        XCTAssertEqual(groupedSet["A"]?.count, 1, "Set at index 'A' should still contain one element")
//        XCTAssertTrue(groupedSet["A"]?.contains(element1) ?? false, "Set at index 'A' should still contain element1")
//    }
//    
//    func test_subscriptForNonExistentIndex() {
//        let groupedSet = GroupedSetIndex<TestElement, String> { $0.category }
//        
//        XCTAssertNil(groupedSet["NonExistent"], "Subscript should return nil for non-existent index")
//    }
//    
//    func test_insertWithNumericIndex() {
//        var groupedSet = GroupedSetIndex<TestElement, Int> { $0.id }
//        let element1 = TestElement(id: 1, category: "A")
//        let element2 = TestElement(id: 2, category: "B")
//        
//        groupedSet.insert(element1)
//        groupedSet.insert(element2)
//        
//        XCTAssertEqual(groupedSet.storage.count, 2, "Storage should contain two indices")
//        XCTAssertEqual(groupedSet[1]?.count, 1, "Set at index 1 should contain one element")
//        XCTAssertEqual(groupedSet[2]?.count, 1, "Set at index 2 should contain one element")
//    }
//    
//    func test_removeLastElementInIndex() {
//        var groupedSet = GroupedSetIndex<TestElement, String> { $0.category }
//        let elementA = TestElement(id: 1, category: "A")
//        let elementB = TestElement(id: 2, category: "B")
//        
//        groupedSet.insert(elementA)
//        groupedSet.insert(elementB)
//        groupedSet.remove(elementB)
//        
//        XCTAssertEqual(groupedSet.storage.count, 1, "Storage should contain only one index")
//        XCTAssertNil(groupedSet["B"], "Set at index 'B' should be nil after removing its only element")
//        XCTAssertNotNil(groupedSet["A"], "Set at index 'A' should still exist")
//    }
//}
