//
//  XyoBridgeQueueRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/25/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/// A repository to facilitate the persistence of a queue, or a series of weights and hashes. It is optional to implement a caching
/// mechanism behind this repo, but it is highly recommended. This repo does not need to persist any data until the
/// commit() function is called. No getter should have a default value.
public protocol XyoBridgeQueueRepository {
    
    /// This function is called every time blocks need to be cleaned from the queue. It is called so that
    /// weights can determine if a hash needs to be removed from the queue.
    /// - Returns: Will return the entire queue, in no particular order. And will return an empty list if
    /// the queue is empty.
    func getQueue () -> [XyoBridgeQueueItem]
    
    /// This function is not currently called in the XYO core, and is only called by certain unit tests. Although it should be
    /// implemented for future use.
    /// - Parameter queue: What state to set the current queue to, it should override the current queue.
    func setQueue (queue : [XyoBridgeQueueItem])
    
    /// This function is called every time a new bound witness is discovered to add to the queue. It does not matter
    /// where this item is added in the queue.
    /// - Parameter item: The bridge queue item to persist in the queue.
    func addQueueItem (item : XyoBridgeQueueItem)
    
    /// This function should remove all of the queue items by their hash. If a hash does not exist, skip over it. This
    /// function is called after every successful bridge is made to keep the storage light.
    /// - Parameter hashes: the hashes to remove from the persisted queue.
    func removeQueueItems (hashes : [XyoObjectStructure])
    
    /// This function should get the lowest weight queue items and return them. It should return the number of parameter n, if the
    /// repo does not have n queue items, it should return the entire queue. There is no particular order the result should be in.
    /// This function is called every time the device is getting ready to bridge.
    /// - Parameter n: The number of lowest weight blocks to return.
    /// - Returns: Should return min(queue.count, n) number of blocks, in no order. These blocks should have the lowest weight in the
    /// queue.
    func getLowestWeight (n : Int) -> [XyoBridgeQueueItem]
    
    /// This function is called every time after a successful bridge event to increment their weights by weight += 1.
    /// - Parameter hashes: The hashes inside of the bridge queue to increment their weights by 1. If a hash does not
    /// exist, it shall be skipped.
    func incrementWeights (hashes: [XyoObjectStructure])
    
    /// This function is called after every bound witness to persist the state of the queue, if there is non caching implemented,
    /// there is no reason to implement this method.
    func commit ()
}
