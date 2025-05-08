import XCTest
import Assemblages

fileprivate struct TestElement {
    static func lessThan (lhs: TestElement, rhs: TestElement) -> Bool {
        lhs.string < rhs.string
    }
    
    var string: String
    var version: Int
}


class IndexSortedArrayTests: XCTestCase {
    
    func testInsert() {
        var array = SortedArrayIndex<TestElement>(lessThan: TestElement.lessThan)
        array.insert(TestElement(string: "c", version: 1))
        array.insert(TestElement(string: "a", version: 1))
        array.insert(TestElement(string: "b", version: 1))
        
        array.insert(TestElement(string: "a", version: 2))
        
        XCTAssertEqual(array[0].string, "a")
        XCTAssertEqual(array[1].string, "a")
        XCTAssertEqual(array[2].string, "b")
        XCTAssertEqual(array[3].string, "c")
    }
    
    func testInserting() {
        let array = SortedArrayIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "c", version: 1))
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "a", version: 2))
        
        XCTAssertEqual(array[0].string, "a")
        XCTAssertEqual(array[1].string, "a")
        XCTAssertEqual(array[2].string, "b")
        XCTAssertEqual(array[3].string, "c")
    }
    
    func testInsertContentsOf() {
        var array = SortedArrayIndex<TestElement>(lessThan: TestElement.lessThan)
        array.insert([
            TestElement(string: "d", version: 1)
            , TestElement(string: "b", version: 1)
            , TestElement(string: "e", version: 1)
            , TestElement(string: "b", version: 2)
        ])
        
        XCTAssertEqual(array[0].string, "b")
        XCTAssertEqual(array[1].string, "b")
        XCTAssertEqual(array[2].string, "d")
        XCTAssertEqual(array[3].string, "e")
    }
    
    func testReduce() {
        let array = SortedArrayIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let result = array.reduce("") { $0 + $1.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testReduceInto() {
        let array = SortedArrayIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let result = array.reduce(into: "") { $0 += $1.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testFilter() {
        let array = SortedArrayIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let filteredSet = array.filter { $0.string != "b" }
        
        XCTAssertEqual(filteredSet.count, 2)
        XCTAssertEqual(filteredSet[0].string, "a")
        XCTAssertEqual(filteredSet[1].string, "c")
    }
    
    func testForEach() {
        let array = SortedArrayIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        var result = ""
        array.forEach { result += $0.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testMap() {
        let array = SortedArrayIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let mapped = array.map { $0.string.uppercased() }
        
        XCTAssertEqual(mapped, ["A", "B", "C"])
    }
    
    func testCompactMap() {
        let array = SortedArrayIndex<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let compactMapped = array.compactMap { $0.string == "b" ? nil : $0.string.uppercased() }
        
        XCTAssertEqual(compactMapped, ["A", "C"])
    }
}
