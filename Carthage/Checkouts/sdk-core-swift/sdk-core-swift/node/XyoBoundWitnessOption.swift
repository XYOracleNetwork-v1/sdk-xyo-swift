//
//  XyoBoundWitnessOption.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/// This interface acts as a way of changing data inside a bound witness based
/// on the flag of the negotiation. This can be added to a node in the XyoOriginChainCreator class
public protocol XyoBoundWitnessOption {
    
    /// This function gets the flags that if set in the bound witness, will call the getPair() and onCompleted()
    /// function of the bound witness. For example, if the bridge flag is set getPair() will be called to get the
    /// blocks and hashes of the blocks to put in the bound witness.
    /// - Returns: The flags to check against for bound witnessing.
    func getFlag () -> [UInt8]
    
    /// This function gets the heuristics to include in the bound witness and is only called when the flags in
    /// getFlags() are set in the bound witness.
    /// - Returns: The heuristics to include in the bound witness, if null, nothing will be added
    func getPair () throws -> XyoBoundWitnessHeuristicPair?
    
    /// This function is called after the bound witness where the proper flags are set is completed.
    /// - Parameter boundWitness: If null, the bound witness failed, if the bound witness is present, it succeded.
    func onCompleted (boundWitness : XyoBoundWitness?)
}
