//
//  XyoNodeListener.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/// This protocol acts as an interface for listening onto nodes. All of its callback methods live
/// in the XyoOriginChainCreator class and can be added through the .addListener() function.
public protocol XyoNodeListener {
    
    /// This function will be called every time a bound witness has started
    func onBoundWitnessStart()
    
    /// This function is called when a bound witness starts, but fails due to an error
    func onBoundWitnessEndFailure()
    
    /// This function is called when the node discovers a new origin block, this is typically its new blocks
    /// that it is creating, but will be called when a bridge discovers new blocks.
    /// - Parameter boundWitness: The boundwitness just discovered
    func onBoundWitnessDiscovered(boundWitness : XyoBoundWitness)
    
    /// This function is called every time a bound witness starts and completes successfully.
    /// - Parameter boundWitness: The boundwitness just completed
    func onBoundWitnessEndSuccess(boundWitness : XyoBoundWitness)
}
