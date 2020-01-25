//
//  CommandTests.swift
//  Command
//
//  Created by Maxim Bazarov on 17.02.19.
//  Copyright © 2019 Maksim Bazarov. All rights reserved.
//

import XCTest
@testable import Unicore

class CommandTests: XCTestCase {


    func testCommand_Execute_ShouldExecuteCommand() {
        let exp = expectation(description: "Should Execute Command")
        let command = Command { _ in
            exp.fulfill()
        }
        command.execute()
        wait(for: [exp], timeout: 0)
    }
    
    func testCommandOfInt_Execute_ShouldExecuteCommand() {
        let exp = expectation(description: "Should Execute Command")
        let command = CommandOf<Int> { _ in
            exp.fulfill()
        }
        command.execute(with: 0)
        wait(for: [exp], timeout: 0)
    }
    
    func testCommandOfInt_BoundWithValue_Execute_ShouldExecuteCommandWithBoundValue() {
        let testValue = 7
        let exp = expectation(description: "Should Execute Command")
        let command = CommandOf<Int> { value in
            guard value == testValue else { return XCTFail("Unexpected value") }
            exp.fulfill()
        }
        let boundCommand = command.bound(to: testValue)
        boundCommand.execute()
        wait(for: [exp], timeout: 0)
    }
    
    func testTwoEqualCommands_Equitable_ShouldBeEqual() {
        let firstCommand = Command{}
        let secondCommand = firstCommand
        
        XCTAssertEqual(firstCommand, secondCommand)
    }
    
    func testTwoCommands_Equitable_ShouldNotBeEqual() {
        let firstCommand = Command{}
        let secondCommand = Command{}
        
        XCTAssertNotEqual(firstCommand, secondCommand)
    }
    
}
