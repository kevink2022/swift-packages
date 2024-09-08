import XCTest
import Combine
@testable import Storage

final class UpdateTests: XCTestCase {
    
    var cancel: AnyCancellable?
    
    func test_directTransaction() async {
        let exp_transaction1 = expectation(description: "first transaction")
        let exp_transaction2 = expectation(description: "second transaction")
        
        var capture1: String?
        var capture2: String?
        
        let transactor = Transactor<String, String>(
            basePost: ""
            , key: "test-transact-direct"
            , inMemory: true
        ) {
            new, post in
            return post + new
        }
        
        cancel = transactor.publisher
            .sink { value in
                guard value != "" else { return }
                if capture1 == nil {
                    capture1 = value
                    exp_transaction1.fulfill()
                } else if capture2 == nil {
                    capture2 = value
                    exp_transaction2.fulfill()
                }
            }
        
        await transactor.commit(transaction: "hello")
        await transactor.commit(transaction: " world")
        
        await fulfillment(of: [exp_transaction1, exp_transaction2], timeout: 1.0, enforceOrder: true)
        
        XCTAssertEqual(capture1, "hello")
        XCTAssertEqual(capture2, "hello world")
    }
    
    func test_generateTransaction() async {
        let exp_transaction1 = expectation(description: "first transaction")
        let exp_transaction2 = expectation(description: "second transaction")
        
        var capture1: String?
        var capture2: String?
        
        let transactor = Transactor<String, String>(
            basePost: ""
            , key: "test-transact-generate"
            , inMemory: true
        ) {
            new, _ in
            return new
        }

        cancel = transactor.publisher
            .sink { value in
                guard value != "" else { return }
                if capture1 == nil {
                    capture1 = value
                    exp_transaction1.fulfill()
                } else if capture2 == nil {
                    capture2 = value
                    exp_transaction2.fulfill()
                }
            }
                
        await transactor.commit(transaction: "hello")
        await transactor.commit { post in
            return post.capitalized + " World"
        }
        
        await fulfillment(of: [exp_transaction1, exp_transaction2], timeout: 1.0, enforceOrder: true)
        
        XCTAssertEqual(capture1, "hello")
        XCTAssertEqual(capture2, "Hello World")
    }
    
    func test_persistence() async {
        let exp_transaction1 = expectation(description: "first transaction")
        let exp_transaction2 = expectation(description: "second transaction")
        
        var capture1: String?
        var capture2: String?
        
        let transactor1 = Transactor<String, String>(
            basePost: ""
            , key: "test-transact-persistence"
            , inMemory: true
        ) {
            new, post in
            return post + new
        }
        
        cancel = transactor1.publisher
            .sink { value in
                guard value != "" else { return }
                if capture1 == nil {
                    capture1 = value
                    exp_transaction1.fulfill()
                }
            }
        
        await transactor1.commit(transaction: "hello")
        await fulfillment(of: [exp_transaction1], timeout: 1.0, enforceOrder: true)
       
        let transactor2 = Transactor<String, String>(
            basePost: ""
            , key: "test-transact-persistence"
            , inMemory: true
        ) {
            new, post in
            return post + new
        }
        
        cancel = transactor2.publisher
            .sink { value in
                guard value != "" && value != "hello" else { return }
                if capture2 == nil {
                    capture2 = value
                    exp_transaction2.fulfill()
                }
            }
        
        await transactor2.commit(transaction: " world")
        await fulfillment(of: [exp_transaction2], timeout: 1.0, enforceOrder: true)
        
        XCTAssertEqual(capture1, "hello")
        XCTAssertEqual(capture2, "hello world")
    }
    
    func test_getAll() async {
        let exp_4commits = expectation(description: #function)
        var captureCount = 0
        
        let transactor = Transactor<String, String>(
            basePost: ""
            , key: "test-transact-getAll"
            , inMemory: true
        ) {
            new, post in
            return post + new
        }
        
        cancel = transactor.publisher
            .sink { value in
                guard value != "" else { return }
                captureCount += 1
                if captureCount == 4 {
                    exp_4commits.fulfill()
                }
            }
        
        await transactor.commit(transaction: "1")
        await transactor.commit(transaction: "2")
        await transactor.commit(transaction: "3")
        await transactor.commit(transaction: "4")
        
        await fulfillment(of: [exp_4commits], timeout: 1.0)
        
        let transactions = await transactor.viewTransactions()
        
        XCTAssertEqual(transactions.count, 4)
        XCTAssertEqual(transactions[0].data, "4")
        XCTAssertEqual(transactions[2].data, "2")
    }
    
    func test_getCount() async {
        let exp_4commits = expectation(description: #function)
        var captureCount = 0
        
        let transactor = Transactor<String, String>(
            basePost: ""
            , key: "test-transact-getCount"
            , inMemory: true
        ) {
            new, post in
            return post + new
        }
        
        cancel = transactor.publisher
            .sink { value in
                guard value != "" else { return }
                captureCount += 1
                if captureCount == 4 {
                    exp_4commits.fulfill()
                }
            }
        
        await transactor.commit(transaction: "1")
        await transactor.commit(transaction: "2")
        await transactor.commit(transaction: "3")
        await transactor.commit(transaction: "4")
        
        await fulfillment(of: [exp_4commits], timeout: 1.0)
        
        let transactions = await transactor.viewTransactions(last: 2)
        
        XCTAssertEqual(transactions.count, 2)
        XCTAssertEqual(transactions[0].data, "4")
        XCTAssertEqual(transactions[1].data, "3")
    }
    
    func test_getByDate() async {
        let exp_4commits = expectation(description: #function)
        var captureCount = 0
        
        let transactor = Transactor<String, String>(
            basePost: ""
            , key: "test-transact-getByDate"
            , inMemory: true
        ) {
            new, post in
            return post + new
        }
        
        cancel = transactor.publisher
            .sink { value in
                guard value != "" else { return }
                captureCount += 1
                if captureCount == 4 {
                    exp_4commits.fulfill()
                }
            }
        
        await transactor.commit(transaction: "1")
        await transactor.commit(transaction: "2")
        await transactor.commit(transaction: "3")
        await transactor.commit(transaction: "4")
        
        await fulfillment(of: [exp_4commits], timeout: 1.0)
        
        let allTransactions = await transactor.viewTransactions()
        let timestamp = allTransactions[1].timestamp
        let recentTransactions = await transactor.viewTransactions(since: timestamp)
        
        XCTAssertEqual(recentTransactions.count, 2)
        XCTAssertEqual(recentTransactions[0].data, "4")
        XCTAssertEqual(recentTransactions[1].data, "3")
    }

    func test_rollbackAfter() async {
        let exp_4commits = expectation(description: "4 commits")
        let exp_rollback = expectation(description: "rollback")
        var captureCount = 0
        
        let transactor = Transactor<String, String>(
            basePost: ""
            , key: "test-transact-rollbackAfter"
            , inMemory: true
        ) {
            new, post in
            return post + new
        }
        
        cancel = transactor.publisher
            .sink { value in
                guard value != "" else { return }
                captureCount += 1
                if captureCount == 4 {
                    exp_4commits.fulfill()
                } else if captureCount == 5 {
                    exp_rollback.fulfill()
                }
            }
        
        await transactor.commit(transaction: "1")
        await transactor.commit(transaction: "2")
        await transactor.commit(transaction: "3")
        await transactor.commit(transaction: "4")
        
        await fulfillment(of: [exp_4commits], timeout: 1.0)
        
        let transactions = await transactor.viewTransactions()
        await transactor.rollbackTo(after: transactions[2])
        
        await fulfillment(of: [exp_rollback], timeout: 1.0)
        
        let rolledBack = await transactor.viewTransactions()
        
        XCTAssertEqual(transactions.count, 4)
        XCTAssertEqual(transactions[0].data, "4")
        XCTAssertEqual(transactions[1].data, "3")
        
        XCTAssertEqual(rolledBack.count, 2)
        XCTAssertEqual(rolledBack[0].data, "2")
        XCTAssertEqual(rolledBack[1].data, "1")
    }
    
    func test_rollbackBefore() async {
        let exp_4commits = expectation(description: "4 commits")
        let exp_rollback = expectation(description: "rollback")
        var captureCount = 0
        
        let transactor = Transactor<String, String>(
            basePost: ""
            , key: "test-transact-rollbackBefore"
            , inMemory: true
        ) {
            new, post in
            return post + new
        }
        
        cancel = transactor.publisher
            .sink { value in
                guard value != "" else { return }
                captureCount += 1
                if captureCount == 4 {
                    exp_4commits.fulfill()
                } else if captureCount == 5 {
                    exp_rollback.fulfill()
                }
            }
        
        await transactor.commit(transaction: "1")
        await transactor.commit(transaction: "2")
        await transactor.commit(transaction: "3")
        await transactor.commit(transaction: "4")
        
        await fulfillment(of: [exp_4commits], timeout: 1.0)
        
        let transactions = await transactor.viewTransactions()
        await transactor.rollbackTo(before: transactions[1])
        
        await fulfillment(of: [exp_rollback], timeout: 1.0)
        
        let rolledBack = await transactor.viewTransactions()
        
        XCTAssertEqual(transactions.count, 4)
        XCTAssertEqual(transactions[0].data, "4")
        XCTAssertEqual(transactions[1].data, "3")
        
        XCTAssertEqual(rolledBack.count, 2)
        XCTAssertEqual(rolledBack[0].data, "2")
        XCTAssertEqual(rolledBack[1].data, "1")
    }
}

