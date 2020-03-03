//
//  XyoStandardInteractionTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 4/8/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoStandardInteractionTest: XCTestCase {
    
    func testStandardInteractionCaseOne () {
        let nodeOne = createNewRelayNode()
        let nodeTwo = createNewRelayNode()
        
        let pipeOne = XyoMemoryPipe()
        let pipeTwo = XyoMemoryPipe()
        
        pipeOne.other = pipeTwo
        pipeTwo.other = pipeOne
        
        let handlerOne = XyoNetworkHandler(pipe: pipeOne)
        let handlerTwo = XyoNetworkHandler(pipe: pipeTwo)
        
        let nodeOneCompletionOne = expectation(description: "Node one should finish bound witness.")
        let nodeTwoCompletionOne = expectation(description: "Node two should finish bound witness.")
        
        nodeOne.boundWitness(handler: handlerOne, procedureCatalogue: TestInteractionCatalogueCaseOne()) { (result, error) in
            // this should complete first
            XCTAssertNil(error, "There should be no error from node one")
            XCTAssertNil(getFetterItem(boundWitness: result!, itemId: XyoSchemas.BRIDGE_HASH_SET.id, partyIndex: 0))
            XCTAssertTrue(correctIndex(boundWitness: result!, partyIndex: 0, indexNum: 1))
            nodeOneCompletionOne.fulfill()
        }
        
        nodeTwo.boundWitness(handler: handlerTwo, procedureCatalogue: TestInteractionCatalogueCaseOne()) { (result, error) in
             // this should complete second
            XCTAssertNil(error, "There should be no error from node one")
            XCTAssertNil(getFetterItem(boundWitness: result!, itemId: XyoSchemas.BRIDGE_HASH_SET.id, partyIndex: 0))
            XCTAssertTrue(correctIndex(boundWitness: result!, partyIndex: 1, indexNum: 1))
            nodeTwoCompletionOne.fulfill()
        }
        
        wait(for: [nodeOneCompletionOne, nodeTwoCompletionOne], timeout: 1)
    }
}
