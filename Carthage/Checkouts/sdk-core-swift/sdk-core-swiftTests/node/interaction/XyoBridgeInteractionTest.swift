//
//  XyoBridgeInteractionTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 4/8/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoBridgeInteractionTest: XCTestCase {
    
    // client bridges to server
    func testBridgeInteractionCaseOne () {
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
        
        // this is index [1]
        nodeOne.boundWitness(handler: handlerOne, procedureCatalogue: TestTakeOriginChainCatalogue()) { (result, error) in
            XCTAssertNil(error, "There should be no error from node one")
            XCTAssertTrue(getFetterItem(boundWitness: result!, itemId: XyoSchemas.BRIDGE_HASH_SET.id, partyIndex: 1) != nil)
            XCTAssertTrue(getFetterItem(boundWitness: result!, itemId: XyoSchemas.BRIDGE_HASH_SET.id, partyIndex: 0) == nil)
            XCTAssertTrue(correctIndex(boundWitness: result!, partyIndex: 0, indexNum: 1))
            nodeOneCompletionOne.fulfill()
        }
        
         // this is index [0]
        nodeTwo.boundWitness(handler: handlerTwo, procedureCatalogue: TestGiveOriginChainCatalogue()) { (result, error) in
            XCTAssertNil(error, "There should be no error from node one")
            XCTAssertTrue(getFetterItem(boundWitness: result!, itemId: XyoSchemas.BRIDGE_HASH_SET.id, partyIndex: 1) != nil)
            XCTAssertTrue(getFetterItem(boundWitness: result!, itemId: XyoSchemas.BRIDGE_HASH_SET.id, partyIndex: 0) == nil)
            XCTAssertTrue(correctIndex(boundWitness: result!, partyIndex: 1, indexNum: 1))
            nodeTwoCompletionOne.fulfill()
        }
        
        wait(for: [nodeOneCompletionOne, nodeTwoCompletionOne], timeout: 1)
    }
    
     // server bridges to client
    func testBridgeInteractionCaseTwo () {
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
        
        // this is index [1]
        nodeOne.boundWitness(handler: handlerOne, procedureCatalogue: TestGiveOriginChainCatalogue()) { (result, error) in
            XCTAssertNil(error, "There should be no error from node one")
            XCTAssertTrue(getFetterItem(boundWitness: result!, itemId: XyoSchemas.BRIDGE_HASH_SET.id, partyIndex: 0) != nil)
            XCTAssertTrue(getFetterItem(boundWitness: result!, itemId: XyoSchemas.BRIDGE_HASH_SET.id, partyIndex: 1) == nil)
            XCTAssertTrue(correctIndex(boundWitness: result!, partyIndex: 0, indexNum: 1))
            nodeOneCompletionOne.fulfill()
        }
        
        // this is index [0]
        nodeTwo.boundWitness(handler: handlerTwo, procedureCatalogue: TestTakeOriginChainCatalogue()) { (result, error) in
            XCTAssertNil(error, "There should be no error from node one")
            XCTAssertTrue(getFetterItem(boundWitness: result!, itemId: XyoSchemas.BRIDGE_HASH_SET.id, partyIndex: 0) != nil)
            XCTAssertTrue(getFetterItem(boundWitness: result!, itemId: XyoSchemas.BRIDGE_HASH_SET.id, partyIndex: 1) == nil)
            XCTAssertTrue(correctIndex(boundWitness: result!, partyIndex: 1, indexNum: 1))
            nodeTwoCompletionOne.fulfill()
        }
        
        wait(for: [nodeOneCompletionOne, nodeTwoCompletionOne], timeout: 1)
    }
}
