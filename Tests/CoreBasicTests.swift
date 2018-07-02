//
//  UnicoreTests.swift
//  UnicoreTests


import XCTest
import FunctionalFoundation

@testable import Unicore


class UnicoreTests: XCTestCase {
    
    
    // MARK: Components
    
    func testComponentSubscribedAndRecevesCurrentState() {
        let exp = expectation(description: "state is right")
        let state = 7
        let sut = Core<Int>(state: state) { _, _ in state }
        sut.observe { value in
            if value == state { exp.fulfill() }
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func testComponentSubscribed_StateHasChanged_ComponentRecevesAllStateChanges() {
        
        enum Fake: Action { case action }
        
        let expectedStateSequence = [7, 2]
        
        var sequence = Array(expectedStateSequence.reversed())
        
        func mutate(_ state: Int, _ action: Action) -> Int {
            return sequence.popLast()!
        }
        
        var result:[Int] = []
        let sut = Core<Int>(state: sequence.popLast()!, mutate: mutate)

        sut.observe { (value) in
            result.append(value)
            if sequence.count > 0 { sut.dispatch(Fake.action) }
        }
        
        XCTAssertEqual(result, expectedStateSequence)
    }
    
    // MARK: Middleware
    
    func testMiddlewareSubscribedAndDontReceveCurrentState() {
        let state = 7
        let sut = Core<Int>(state: state) { _, _ in state }
        sut.listen { (_, _) in
            XCTFail()
        }
    }
    
    func testMiddlewareSubscribed_StateHasChanged_MiddlewareRecevesStateBeforeChangesAndAction() {
        
        enum Fake: Action { case action }
        
        let firstValue = 7
        let secondValue = 2
        let expectedStateSequence = [firstValue, secondValue]
        let exp = expectation(description: "action and state is right")
        
        var sequence = Array(expectedStateSequence.reversed())
        
        func mutate(_ state: Int, _ action: Action) -> Int {
            return sequence.popLast()!
        }
        
        let sut = Core<Int>(state: sequence.popLast()!, mutate: mutate)
        
        sut.listen { value, action in
            if value == firstValue, action is Fake {
                exp.fulfill()
            } else {
                XCTFail()
            }
            
        }
        
        sut.dispatch(Fake.action)
        
        wait(for: [exp], timeout: 0.5)
    }
}
