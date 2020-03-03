//
//  XyoOriginBlockRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/// A repository to store origin blocks in a persistent manner. These functions are called as often as
/// a device does bound witnesses. This repo should be optimized for containsOriginBlock() as it is called
/// the most.
/// - Warning: Make sure hashing algorithms are consistent with the program, or else blocks may leak.
public protocol XyoOriginBlockRepository {
    
    /// This function should remove an origin block by its hash from the repository and update the persisted state.
    /// - Warning: Make sure hashing algorithms are consistent with the program, or else blocks may leak.
    /// - Parameter originBlockHash: The hash of the block to remove, if none is found, skip.
    func removeOriginBlock (originBlockHash : [UInt8]) throws
    
    /// This function gets an origin block by its hash
    /// - Warning: Make sure hashing algorithms are consistent with the program, or else blocks may leak.
    /// - Parameter originBlockHash: The hash of the block to get.
    /// - Returns: The origin block pertaining to the hash, if none is found, return nil.
    func getOriginBlock (originBlockHash : [UInt8]) throws -> XyoBoundWitness?
    
    /// This function should check if an origin block is found in the repo. This should be optimized given
    /// this it is called often.
    /// - Warning: Make sure hashing algorithms are consistent with the program, or else blocks may leak.
    /// - Parameter originBlockHash: The hash of the block to check if it is in the repo.
    /// - Returns: Will return if the repo contains an origin block.
    func containsOriginBlock (originBlockHash : [UInt8]) throws -> Bool
    
    /// This function adds an origin block to the repo.
    /// TODO: Add hash to the parameters so that hashing algorithms do not have to be consistent.
    /// - Warning: Make sure hashing algroithms are consistent with the program, or else blocks may leak.
    /// - Parameter originBlock: The block to add to the repo.
    func addOriginBlock (originBlock : XyoBoundWitness) throws
}
