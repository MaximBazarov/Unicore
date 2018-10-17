//
//  DisposerTests.swift
//  UnicoreTests
//
//  Created by Maksim Bazarov on 17.10.18.
//  Copyright © 2018 Maksim Bazarov. All rights reserved.
//

import XCTest
@testable import Unicore


class DisposerTests: XCTestCase {

    func testDispose_AddOneDisposal_shouldCallDisposalsWhenDisposerDeinits() {
        let exp = expectation(description: "Disposer must execute command when deinits")
        var disposer: Disposer? = Disposer()
        disposer!.add(disposal: PlainCommand {
            exp.fulfill()
        })
        disposer = nil
        wait(for: [exp], timeout: 1)
    }

    func testDispose_AddMultiple_shouldCallAllDisposalsWhenDisposerDeinits() {
    
        let exp1 = expectation(description: "Disposer must execute command when deinits")
        let exp2 = expectation(description: "Disposer must execute command when deinits")
        
        var disposer: Disposer? = Disposer()
        
        disposer!.add(disposal: PlainCommand {
            exp1.fulfill()
        })
        
        disposer!.add(disposal: PlainCommand {
            exp2.fulfill()
        })

        
        disposer = nil
        wait(for: [exp1,exp2], timeout: 3)
    }
    
    // MARK: Syntax sugar
    
    func testPlainCommand_DisposeOn_shouldCallDisposalsWhenDisposerDeinits() {
        let exp = expectation(description: "Disposer must execute command when deinits")
        var disposer: Disposer? = Disposer()
        
        PlainCommand {
            exp.fulfill()
        }.dispose(on: disposer!)
        
        disposer = nil
        wait(for: [exp], timeout: 1)
    }
    
    func testMultiplePlainCommands_DisposeOn_shouldCallAllDisposalsWhenDisposerDeinits() {
        
        let exp1 = expectation(description: "Disposer must execute command when deinits")
        let exp2 = expectation(description: "Disposer must execute command when deinits")
        
        var disposer: Disposer? = Disposer()
        
        PlainCommand {
            exp1.fulfill()
        }.dispose(on: disposer!)
        
        PlainCommand {
            exp2.fulfill()
        }.dispose(on: disposer!)
        
        
        disposer = nil
        wait(for: [exp1,exp2], timeout: 3)
    }
}
