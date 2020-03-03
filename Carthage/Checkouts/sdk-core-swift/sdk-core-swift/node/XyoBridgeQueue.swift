//
//  XyoBridgeQueue.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation


/// This class is meant to hold hashes and a value so that one can maintain a list of blocks that
/// they need to offload. This is used by the XyoRelayNode. Both sentinels and bridges need this
// functionality.
public class XyoBridgeQueue {
    
    /// The place to store and persist the bridge queue blocks
    public let repo : XyoBridgeQueueRepository
    
    /// The max number of blocks to get when sending blocks. (The max number of blocks that
    /// getBlocksToBridge() returns)
    public var sendLimit = 10
    
    /// How many times to bridge a block before it should be removed from the queue, after this
    /// happens, the hash of the block can be retrieved from getBlocksToRemove()
    public var removeWeight = 3
    
    /// Creates a new instance of XyoBridgeQueue
    /// - Parameter repository:
    public init (repository : XyoBridgeQueueRepository) {
        self.repo = repository
    }
    
    func addBlock (blockHash : XyoObjectStructure) {
        addBlock(blockHash: blockHash, weight: 0)
    }
    
    func addBlock (blockHash : XyoObjectStructure, weight : Int) {
        let newQueueItem = XyoBridgeQueueItem(weight: weight, hash: blockHash)
        repo.addQueueItem(item: newQueueItem)
    }
    
    func getBlocksToBridge() -> [XyoBridgeQueueItem] {
        return repo.getLowestWeight(n: sendLimit)
    }
    
    func onBlocksBridged (blocks : [XyoBridgeQueueItem]) {
        var hashes = [XyoObjectStructure]()
        
        for block in blocks {
            hashes.append(block.hash)
        }
        
        repo.incrementWeights(hashes: hashes)
    }
    
    // it is possible to leak blocks if this function is called, the blocks are removed in the queue, before the block repository.
    func getBlocksToRemove () -> [XyoObjectStructure] {
        let blocksToBridge = repo.getQueue()
        var toRemoveHashes = [XyoObjectStructure]()
        
        for i in (0..<blocksToBridge.count).reversed() {
            if (blocksToBridge[i].weight >= removeWeight) {
                let hash = blocksToBridge[i].hash
                toRemoveHashes.append(hash)
            }
        }
        
        repo.removeQueueItems(hashes: toRemoveHashes)
        return toRemoveHashes
    }
}
