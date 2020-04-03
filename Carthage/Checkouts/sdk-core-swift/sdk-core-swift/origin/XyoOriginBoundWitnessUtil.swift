//
//  XyoOriginBoundWitnessUtil.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/// A struct to help with the orgin related utilities of an origin chain. These functions are concepts related
/// to origin blocks, not bound witnesses.
public struct XyoOriginBoundWitnessUtil {
    
    /// This function extracts the bridge blocks from the bound witnesses, if none is found,
    /// will return nil. This function will return the bridged blocks from the first party that has it.
    /// - Parameter boundWitness:  The bound witness to extract the bridged blocks from.
    /// - Returns: The bridged blocks of the first party that has it, if any.
    public static func getBridgedBlocks (boundWitness : XyoBoundWitness) throws -> XyoIterableStructure? {
        let witnesses = try boundWitness.get(id: XyoSchemas.WITNESS.id)
        
        for witness in witnesses {
            guard let typedWitness = witness as? XyoIterableStructure else {
                throw XyoError.MUST_BE_FETTER_OR_WITNESS
            }
            
            let blockset = try typedWitness.get(id: XyoSchemas.BRIDGE_BLOCK_SET.id)

            for item in blockset {
                return item as? XyoIterableStructure
            }
        }
        
        return nil
    }
    
}
