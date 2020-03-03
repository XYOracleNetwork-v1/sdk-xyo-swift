//
//  XyoNodeCreator.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 4/8/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_core_swift

func createNewRelayNode () -> XyoRelayNode {
    do {
        let storage = XyoInMemoryStorage()
        let blocks = XyoStorageProviderOriginBlockRepository(storageProvider: storage,hasher: XyoSha256())
        let state = XyoStorageOriginStateRepository(storage: storage)
        let conf = XyoRepositoryConfiguration(originState: state, originBlock: blocks)
        
        let node = XyoRelayNode(hasher: XyoSha256(),
                                repositoryConfiguration: conf,
                                queueRepository: XyoStorageBridgeQueueRepository(storage: storage))
        
        try node.selfSignOriginChain()
        
        return node
    } catch {
        fatalError("Node should be able to sign its chain")
    }
}
