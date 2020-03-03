//
//  XyoRelayNode.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

open class XyoRelayNode : XyoOriginChainCreator, XyoNodeListener {
   
    
    private static let LISTENER_KEY = "RELAY_NODE"
    private static let OPTION_KEY = "BRIDING_OPTION"
    
    public let blocksToBridge : XyoBridgeQueue
    private let bridgeOption : XyoBridgingOption
    
    public init(hasher: XyoHasher,
                repositoryConfiguration : XyoRepositoryConfiguration,
                queueRepository: XyoBridgeQueueRepository) {
        
        self.blocksToBridge = XyoBridgeQueue(repository: queueRepository)
        bridgeOption = XyoBridgingOption(bridgeQueue: blocksToBridge, originBlockRepository: repositoryConfiguration.originBlock)
        
        super.init(hasher: hasher, repositoryConfiguration: repositoryConfiguration)
        
        addListener(key: XyoRelayNode.LISTENER_KEY, listener: self)
        addBoundWitnessOption(key: XyoRelayNode.OPTION_KEY, option: bridgeOption)
    }
    
    public func onBoundWitnessDiscovered(boundWitness: XyoBoundWitness) {
        do {
            blocksToBridge.addBlock(blockHash: try boundWitness.getHash(hasher: hasher))
        } catch {
            // do not add block to queue if there is an issue with getting its hash
        }
    }
    
    public func onBoundWitnessEndSuccess(boundWitness : XyoBoundWitness) {
        do {            
            for hash in blocksToBridge.getBlocksToRemove() {
                try repositoryConfiguration.originBlock.removeOriginBlock(originBlockHash: hash.getBuffer().toByteArray())
            }
            
            originState.repo.commit()
            blocksToBridge.repo.commit()
        } catch {
            // do not add block to queue if there is an issue with getting its hash
        }
    }
    
    public func onBoundWitnessEndFailure() { }
    public func onBoundWitnessStart() {}
}
