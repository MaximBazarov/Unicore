//
//  UnicoreTests.swift
//  UnicoreTests


import XCTest

@testable import Unicore


class UnicoreTests: XCTestCase {
    
    let disposer = Disposer()
    struct FakeAction: Action {}
    
    // MARK: Components
    
    func testComponentSubscribedAndRecevesCurrentState() {
        let exp = expectation(description: "state is right")
        let state = 7
        let sut = Core<Int>(state: state) { _, _ in state }
        sut.observe { value in
            if value == state { exp.fulfill() }
        }.dispose(on: disposer)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testComponentSubscribed_StateHasChanged_ComponentRecevesAllStateChanges() {
        let expectedStateSequence = [7, 2]
        
        var sequence = Array(expectedStateSequence.reversed())
        
        func mutate(_ state: Int, _ action: Action) -> Int {
            return sequence.popLast()!
        }
        
        var result:[Int] = []
        let sut = Core<Int>(state: sequence.popLast()!, reducer: mutate)

        sut.observe { (value) in
            result.append(value)
            if sequence.count > 0 { sut.dispatch(FakeAction()) }
        }.dispose(on: disposer)
        
        XCTAssertEqual(result, expectedStateSequence)
    }
    
    // MARK: Middleware
    
    func testMiddlewareSubscribedAndDontReceveCurrentState() {
        let state = 7
        let sut = Core<Int>(state: state) { _, _ in state }
        sut.add { (_, _) in
            XCTFail()
        }.dispose(on: disposer)
    }
    
    func testMiddlewareSubscribed_StateHasChanged_MiddlewareRecevesStateBeforeChangesAndAction() {
        
        let firstValue = 7
        let secondValue = 2
        let expectedStateSequence = [firstValue, secondValue]
        let exp = expectation(description: "action and state is right")
        
        var sequence = Array(expectedStateSequence.reversed())
        
        func mutate(_ state: Int, _ action: Action) -> Int {
            return sequence.popLast()!
        }
        
        let sut = Core<Int>(state: sequence.popLast()!, reducer: mutate)
        
        sut.add { value, action in
            if value == firstValue, action is FakeAction {
                exp.fulfill()
            } else {
                XCTFail()
            }
            
        }.dispose(on: disposer)
        
        sut.dispatch(FakeAction())
        
        wait(for: [exp], timeout: 0.5)
    }
}
