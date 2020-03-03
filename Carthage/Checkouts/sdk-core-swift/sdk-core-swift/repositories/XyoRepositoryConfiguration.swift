//
//  XyoRepositoryConfiguration.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 3/3/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public struct XyoRepositoryConfiguration {
    public let originState : XyoOriginChainStateRepository
    public let originBlock : XyoOriginBlockRepository
    
    public init(originState : XyoOriginChainStateRepository, originBlock: XyoOriginBlockRepository) {
        self.originState = originState
        self.originBlock = originBlock
    }
}
