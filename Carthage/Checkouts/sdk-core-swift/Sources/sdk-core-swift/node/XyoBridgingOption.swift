//
//  XyoBridgingOption.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

class XyoBridgingOption: XyoBoundWitnessOption {
    private var blocksInTransit = [XyoBridgeQueueItem]()
    private let bridgeQueue : XyoBridgeQueue
    private let originBlockRepository : XyoOriginBlockRepository
    
    init(bridgeQueue: XyoBridgeQueue, originBlockRepository: XyoOriginBlockRepository) {
        self.bridgeQueue = bridgeQueue
        self.originBlockRepository = originBlockRepository
    }
    
    func getFlag () -> [UInt8] {
        return [UInt8(XyoProcedureCatalogFlags.TAKE_ORIGIN_CHAIN)]
    }
    
    func getPair() throws -> XyoBoundWitnessHeuristicPair? {
        blocksInTransit = bridgeQueue.getBlocksToBridge()
        var blocks = [XyoObjectStructure]()
        var blockHashes = [XyoObjectStructure]()
        
        for block in blocksInTransit {
            let boundWitness = try originBlockRepository.getOriginBlock(originBlockHash: block.hash.getBuffer().toByteArray())
            
            if (boundWitness != nil) {
                blockHashes.append(block.hash)
                blocks.append(boundWitness.unsafelyUnwrapped)
            }
        }
        
        if (blockHashes.count > 0) {
            let hashSet = try XyoIterableStructure.createTypedIterableObject(schema: XyoSchemas.BRIDGE_HASH_SET, values: blockHashes)
            let blockSet = XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.BRIDGE_BLOCK_SET, values: blocks)

            return XyoBoundWitnessHeuristicPair(signedPayload: [hashSet], unsignedPayload: [blockSet])
        }

        return nil
    }
    
    func onCompleted(boundWitness: XyoBoundWitness?) {
        bridgeQueue.onBlocksBridged(blocks: blocksInTransit)
    }
}
