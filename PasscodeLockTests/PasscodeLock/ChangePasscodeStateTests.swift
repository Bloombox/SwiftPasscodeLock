//
//  ChangePasscodeStateTests.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import XCTest

class ChangePasscodeStateTests: XCTestCase {
    
    var passcodeLock: FakePasscodeLock!
    var passcodeState: ChangePasscodeState!
    var repository: FakePasscodeRepository!
    
    override func setUp() {
        super.setUp()
        
        repository = FakePasscodeRepository()
        
        let config = FakePasscodeLockConfiguration(repository: repository)
        
        passcodeState = ChangePasscodeState()
        passcodeLock = FakePasscodeLock(state: passcodeState, configuration: config)
    }
    
    func testAcceptCorrectPasscode() {
        
        class MockDelegate: FakePasscodeLockDelegate {
            
            var didChangedState = false
            
            override func passcodeLockDidChangeState(_ lock: PasscodeLock) {
                
                didChangedState = true
            }
        }
        
        let delegate = MockDelegate()
        
        passcodeLock.delegate = delegate
        if let newState = passcodeState.accept(passcode: repository.fakePasscode, from: passcodeLock) {
            passcodeLock.changeState(newState)
        }
        
        XCTAssert(passcodeLock.state is SetPasscodeState, "Should change the state to SetPasscodeState")
        XCTAssertEqual(delegate.didChangedState, true, "Should call the delegate when the passcode is correct")
    }
    
    func testAcceptIncorrectPasscode() {
        
        class MockDelegate: FakePasscodeLockDelegate {
            
            var called = false
            
            override func passcodeLockDidFail(_ lock: PasscodeLock) {
                
                called = true
            }
        }
        
        let delegate = MockDelegate()
        
        passcodeLock.delegate = delegate
        passcodeState.accept(passcode: "0000", from: passcodeLock)
        
        XCTAssertEqual(delegate.called, true, "Should call the delegate when the passcode is incorrect")
    }
}
