//
//  IndexSortedKeySetTests.swift
//  Assemblages
//
//  Created by Kevin Kelly on 11/27/24.
//

import XCTest
@testable import Assemblages

private final class Test: Identifiable, Comparable {
    let id: Int
    let value: String
    
    init(id: Int, value: String) {
        self.id = id
        self.value = value
    }
    
    static func == (lhs: Test, rhs: Test) -> Bool {
        lhs.id == rhs.id
        && lhs.value == rhs.value
    }
    
    static func < (lhs: Test, rhs: Test) -> Bool {
        lhs.value < rhs.value
    }
}

final class IndexSortedKeySetTests: XCTestCase {
    
    func test_insertAndRemove() {
        let a1 = Test(id: 1, value: "A")
        let b2 = Test(id: 2, value: "B")
        
        var sut = IndexSortedKeySet<Test>(lessThan: <)
        
        sut.insert(a1)
        sut.insert(b2)
        
        XCTAssertEqual(sut.contains(a1), true)
        XCTAssertEqual(sut.contains(b2), true)
        XCTAssertEqual(a1, sut[a1])
        XCTAssertEqual(b2, sut[b2])
        XCTAssertEqual(a1, sut[a1.id])
        XCTAssertEqual(b2, sut[b2.id])
        
        sut.remove(b2)
        
        XCTAssertEqual(sut.contains(a1), true)
        XCTAssertEqual(sut.contains(b2), false)
        XCTAssertEqual(a1, sut[a1])
        XCTAssertEqual(nil, sut[b2])
        XCTAssertEqual(a1, sut[a1.id])
        XCTAssertEqual(nil, sut[b2.id])
    }
    
    func test_insertAndRemoveImmutable() {
        let a1 = Test(id: 1, value: "A")
        let b2 = Test(id: 2, value: "B")
        
        let sut1 = IndexSortedKeySet<Test>(lessThan: <)
        
        let sut2 = sut1.inserting(a1)
        let sut3 = sut2.inserting(b2)
        
        XCTAssertEqual(sut3.contains(a1), true)
        XCTAssertEqual(sut3.contains(b2), true)
        XCTAssertEqual(a1, sut3[a1])
        XCTAssertEqual(b2, sut3[b2])
        XCTAssertEqual(a1, sut3[a1.id])
        XCTAssertEqual(b2, sut3[b2.id])
        
        let sut4 = sut3.removing(b2)
        
        XCTAssertEqual(sut4.contains(a1), true)
        XCTAssertEqual(sut4.contains(b2), false)
        XCTAssertEqual(a1, sut4[a1])
        XCTAssertEqual(nil, sut4[b2])
        XCTAssertEqual(a1, sut4[a1.id])
        XCTAssertEqual(nil, sut4[b2.id])
    }
    
    func test_insertAndRemoveList() {
        let a1 = Test(id: 1, value: "A")
        let b2 = Test(id: 2, value: "B")
        let c3 = Test(id: 3, value: "C")
        let d4 = Test(id: 4, value: "D")
        
        var sut = IndexSortedKeySet<Test>(lessThan: <)
        
        sut.insert([a1, b2, c3, d4])
        
        XCTAssertEqual(sut.count, 4)
        
        sut.remove([b2, d4])
        
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut.contains(a1), true)
        XCTAssertEqual(sut.contains(b2), false)
        XCTAssertEqual(sut.contains(c3), true)
        XCTAssertEqual(sut.contains(d4), false)
    }
    
    func test_insertAndRemoveListImmutable() {
        let a1 = Test(id: 1, value: "A")
        let b2 = Test(id: 2, value: "B")
        let c3 = Test(id: 3, value: "C")
        let d4 = Test(id: 4, value: "D")
        
        let sut1 = IndexSortedKeySet<Test>(lessThan: <)
        
        let sut2 = sut1.inserting([a1, b2, c3, d4])
        
        XCTAssertEqual(sut2.count, 4)
        
        let sut3 = sut2.removing([b2, d4])
        
        XCTAssertEqual(sut3.count, 2)
        XCTAssertEqual(sut3.contains(a1), true)
        XCTAssertEqual(sut3.contains(b2), false)
        XCTAssertEqual(sut3.contains(c3), true)
        XCTAssertEqual(sut3.contains(d4), false)
    }
    
    func test_checkCollision() {
        let a1 = Test(id: 1, value: "A")
        let b1 = Test(id: 1, value: "B")
        
        var sut = IndexSortedKeySet<Test>(lessThan: <)
        
        sut.insert(a1)
        
        XCTAssertEqual(sut.contains(b1), true)
        XCTAssertEqual(a1, sut[b1])
        XCTAssertEqual(a1, sut[b1.id])
    }
    
    func test_reduceIntoSelf() {
        let a1 = Test(id: 1, value: "A")
        let b2 = Test(id: 2, value: "B")
        
        let sut1 = IndexSortedKeySet<Test>(lessThan: <)
            .inserting(a1)
            .inserting(b2)
        
        
        let sut2 = sut1.reduce(into: IndexSortedKeySet<Test>(lessThan: <)) { newSet, test in
            newSet.insert(Test(id: test.id, value: test.value + "2"))
        }
        
        XCTAssertEqual(sut2[a1]?.value, a1.value + "2")
        XCTAssertEqual(sut2[b2]?.value, b2.value + "2")
    }
    
    func test_reduceIntoSelfImmutable() {
        let a1 = Test(id: 1, value: "A")
        let b2 = Test(id: 2, value: "B")
        
        let sut1 = IndexSortedKeySet<Test>(lessThan: <)
            .inserting(a1)
            .inserting(b2)
        
        let sut2: IndexSortedKeySet<Test> = sut1.reduce(IndexSortedKeySet<Test>(lessThan: <)) { newSet, test in
            newSet.inserting(Test(id: test.id, value: test.value + "2"))
        }
        
        XCTAssertEqual(sut2[a1]?.value, a1.value + "2")
        XCTAssertEqual(sut2[b2]?.value, b2.value + "2")
    }
    
    func test_filter() {
        let a1 = Test(id: 1, value: "A")
        let b2 = Test(id: 2, value: "B")
        let c3 = Test(id: 3, value: "C")
        let d4 = Test(id: 4, value: "D")
        
        let sut1 = IndexSortedKeySet<Test>(lessThan: <)
            .inserting(a1)
            .inserting(b2)
            .inserting(c3)
            .inserting(d4)
        
        let sut2 = sut1.filter { test in
            test.id % 2 == 0
        }
        
        XCTAssertEqual(sut1.contains(a1), true)
        XCTAssertEqual(sut1.contains(b2), true)
        XCTAssertEqual(sut1.contains(c3), true)
        XCTAssertEqual(sut1.contains(d4), true)
        XCTAssertEqual(sut2.contains(a1), false)
        XCTAssertEqual(sut2.contains(b2), true)
        XCTAssertEqual(sut2.contains(c3), false)
        XCTAssertEqual(sut2.contains(d4), true)
    }
    
    func test_forEach() {
        let a1 = Test(id: 1, value: "A")
        let b2 = Test(id: 2, value: "B")
        let c3 = Test(id: 3, value: "C")
        let d4 = Test(id: 4, value: "D")
        
        let sut = IndexSortedKeySet<Test>(lessThan: <)
            .inserting(a1)
            .inserting(b2)
            .inserting(c3)
            .inserting(d4)
        
        var strings = [String]()
        
        sut.forEach { test in
            strings.append(test.value)
        }
        
        let string = strings
            .sorted()
            .reduce("") { partialResult, char in partialResult + char }
        
        XCTAssertEqual(string, "ABCD")
    }
    
    /// Inserting an element with the same ID but sorted differently on the Index will cause it to be inseting twice in the sorted set.
    func test_sameIdNewSortInsert() {
        let a1 = Test(id: 1, value: "A")
        let b2 = Test(id: 2, value: "B")
        let c3 = Test(id: 3, value: "C")
        let d4 = Test(id: 4, value: "D")
        
        /// Will be sorted at the end. a1 should be removed.
        let e1 = Test(id: 1, value: "E")
        
        let sut = IndexSortedKeySet<Test>(lessThan: <)
            .inserting(a1)
            .inserting(b2)
            .inserting(c3)
            .inserting(d4)
            .inserting(e1)
        
        XCTAssertEqual(sut.count, 4)
        XCTAssertEqual(sut.values[0].id, a1.id)
        XCTAssertEqual(sut.values[0].value, a1.value)
        XCTAssertEqual(sut.values[3].id, d4.id)
        XCTAssertEqual(sut.values[3].value, d4.value)
    }
    
    /// Inserting an element with the same ID but sorted differently on the Index will cause it to be inseting twice in the sorted set.
    func test_sameIdNewSortUpdate() {
        let a1 = Test(id: 1, value: "A")
        let b2 = Test(id: 2, value: "B")
        let c3 = Test(id: 3, value: "C")
        let d4 = Test(id: 4, value: "D")
        
        /// Will be sorted at the end. a1 should be removed.
        let e1 = Test(id: 1, value: "E")
        
        let sut = IndexSortedKeySet<Test>(lessThan: <)
            .updating(with: a1)
            .updating(with: b2)
            .updating(with: c3)
            .updating(with: d4)
            .updating(with: e1)
        
        XCTAssertEqual(sut.count, 4)
        XCTAssertEqual(sut.values[0].id, b2.id)
        XCTAssertEqual(sut.values[0].value, b2.value)
        XCTAssertEqual(sut.values[3].id, e1.id)
        XCTAssertEqual(sut.values[3].value, e1.value)
    }
    
    /// Inserting an element with the same sort but sorted new Id should insert a new value, but is currently overwriting the value with the same sort
    func test_sameSortNewId() {
        let a1 = Test(id: 1, value: "A")
        let b2 = Test(id: 2, value: "B")
        let c3 = Test(id: 3, value: "C")
        let d4 = Test(id: 4, value: "D")
        
        /// Will be abritrarily places within the range of equal sort, but will not remove a1
        let a5 = Test(id: 5, value: "A")
        
        let sut = IndexSortedKeySet<Test>(lessThan: <)
            .inserting(a1)
            .inserting(b2)
            .inserting(c3)
            .inserting(d4)
            .inserting(a5)
        
        XCTAssertEqual(sut.count, 5)
        XCTAssertEqual(sut.values[2], b2)
        
        if sut.values[0] == a1 {
            XCTAssertEqual(sut.values[1], a5)
        }
        else {
            XCTAssertEqual(sut.values[0], a5)
            XCTAssertEqual(sut.values[1], a1)
        }
    }
}
