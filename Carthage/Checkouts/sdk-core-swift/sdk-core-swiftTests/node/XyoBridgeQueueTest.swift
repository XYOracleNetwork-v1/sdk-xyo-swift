//
//  XyoBridgeQueueTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoBridgeQueueTest: XCTestCase {
    
    func testBridgeQueueWhenRemoveWeightIsSmallerThanSendSize () throws {
        let storage = XyoInMemoryStorage()
        let repo = XyoStorageBridgeQueueRepository(storage: storage)
        let queue = XyoBridgeQueue(repository: repo)
        let numberOfBlocks = 1000
        var numberOfBlocksOffloaded = 0
        var payloadsSent = 0
        var tempQueue = [XyoBridgeQueueItem]()
        queue.removeWeight = 3
        queue.sendLimit = 10
        
        for i in 0...numberOfBlocks - 1 {
            tempQueue.append(XyoBridgeQueueItem(weight: 0, hash: XyoObjectStructure.newInstance(schema: XyoSchemas.STUB_HASH, bytes: XyoBuffer().put(bits: UInt32(i)))))
        }
        
        repo.setQueue(queue: tempQueue)
        
        while repo.getQueue().count > 0 {
            let blocksToBridge = queue.getBlocksToBridge()
            payloadsSent += 1
            numberOfBlocksOffloaded += blocksToBridge.count
            
            queue.onBlocksBridged(blocks: blocksToBridge)

            _ = queue.getBlocksToRemove()
        }
        
        XCTAssertEqual(queue.removeWeight * numberOfBlocks, numberOfBlocksOffloaded)
        XCTAssertEqual((numberOfBlocks / queue.sendLimit) * queue.removeWeight, payloadsSent)
    }
    
}
