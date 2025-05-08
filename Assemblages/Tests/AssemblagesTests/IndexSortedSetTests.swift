import XCTest
import Assemblages

fileprivate struct TestElement {
    static func lessThan (lhs: TestElement, rhs: TestElement) -> Bool {
        lhs.string < rhs.string
    }
    
    var string: String
    var version: Int
}

extension TestElement: Codable {}

class IndexSortedSetTests: XCTestCase {
    
    func testInsert() {
        var set = SortedSetIndex<TestElement>(lessThan: TestElement.lessThan)
        set.insert(TestElement(string: "c", version: 1))
        set.insert(TestElement(string: "a", version: 1))
        set.insert(TestElement(string: "b", version: 1))
        
        set.insert(TestElement(string: "a", version: 2))
        
        XCTAssertEqual(set[0].string, "a")
        XCTAssertEqual(set[0].version, 1)
        XCTAssertEqual(set[1].string, "b")
        XCTAssertEqual(set[2].string, "c")
    }
    
    func testUpdate() {
        var set = SortedSetIndex<TestElement>(lessThan: TestElement.lessThan)
        set.update(with: TestElement(string: "c", version: 1))
        set.update(with: TestElement(string: "a", version: 1))
        set.update(with: TestElement(string: "b", version: 1))

        set.update(with: TestElement(string: "a", version: 2))
        
        XCTAssertEqual(set[0].string, "a")
        XCTAssertEqual(set[0].version, 2)
        XCTAssertEqual(set[1].string, "b")
        XCTAssertEqual(set[2].string, "c")
    }
    
    func testRemove() {
        var set = SortedSetIndex<TestElement>(lessThan: TestElement.lessThan)
        set.insert([
            TestElement(string: "a", version: 1)
            , TestElement(string: "b", version: 1)
            , TestElement(string: "c", version: 1)
        ])
        
        set.remove(TestElement(string: "b", version: 1))
        
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set[0].string, "a")
        XCTAssertEqual(set[1].string, "c")
    }
        
    func testReduce() {
        let set = SortedSetIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let result = set.reduce("") { $0 + $1.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testReduceInto() {
        let set = SortedSetIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let result = set.reduce("") { $0 + $1.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testFilter() {
        let set = SortedSetIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
    
        let filteredSet = set.filter { $0.string != "b" }
    
        XCTAssertEqual(filteredSet.count, 2)
        XCTAssertEqual(filteredSet[0].string, "a")
        XCTAssertEqual(filteredSet[1].string, "c")
    }
    
    func testForEach() {
        let set = SortedSetIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        var result = ""
        set.forEach { result += $0.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testMap() {
        let set = SortedSetIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let mapped = set.map { $0.string.uppercased() }
        
        XCTAssertEqual(mapped, ["A", "B", "C"])
    }
    
    func testCompactMap() {
        let set = SortedSetIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let compactMapped = set.compactMap { $0.string == "b" ? nil : $0.string.uppercased() }
        
        XCTAssertEqual(compactMapped, ["A", "C"])
    }
}
