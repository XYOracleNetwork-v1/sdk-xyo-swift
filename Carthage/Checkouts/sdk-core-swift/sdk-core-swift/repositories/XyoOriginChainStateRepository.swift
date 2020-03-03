//
//  XyoOriginChainStateRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/25/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/// A repository to facilitate the storage of origin chain state related items. It is optional to implement a caching
/// mechanism behind this repo, but it is highly recomended. This repo does not need to persist any data until the
/// commit() function is called. No getter should have a defualt value.
public protocol XyoOriginChainStateRepository {
    
    /// This function gets the index from the repo, and should return null if none exists. This function
    /// is called before every bound witness.
    /// - Returns: The Index of the repo, and will return null if one does not exist.
    func getIndex () -> XyoObjectStructure?
    
    /// This function should persist the state of the index after the commit() function is called.
    /// This function is called after every bound witness.
    /// - Parameter index: The index object to persist when getIndex is called.
    func putIndex (index : XyoObjectStructure)
    
    /// This function gets the previous hash from the repo, and should return null if none exists.
    /// This function is called before every bound witness.
    /// - Returns: The previous hash of the repo, and will return null if one does not exist.
    func getPreviousHash () -> XyoObjectStructure?
    
    /// This function should persist the state of the previous hash after the commit() function is called.
    /// This function is called after every bound witness.
    /// - Parameter hash: The previous hash object to persist when getPreviousHash is called.
    func putPreviousHash (hash : XyoObjectStructure)
    
    /// This function should get all of the current signers that are being persisted.
    /// This function is called called before evey bound witness to get the signers to sign with. The value of the signers
    /// should never change without the putSigner() function being called on an XyoOriginChainState instance.
    /// - Returns: Will return a list of all of the current signers in the repo. Will never return nil, but will return an
    /// empty list.
    func getSigners () -> [XyoSigner]
    
    /// This function should remove getSigners()[0], or not remove the oldest signer if none are in the repo.
    /// This function is called whenever a user is rotating keys.
    func removeOldestSigner()
    
    /// This function should add a signer to the end of the signer list.
    /// This function is only called when a user wants to rotate kets.
    /// - Parameter signer: The signer to add to the end of the list, and should be persisted.
    func putSigner (signer : XyoSigner)
    
    /// This function is called after every bound witness to persist the state, if there is non caching implemented,
    /// there is no reason to implement this method.
    func commit ()
    
    func setStaticHeuristics (heuristics: [XyoObjectStructure])
    
    func getStaticHeuristics () -> [XyoObjectStructure]
    
    func onBoundWitness ()
    
    func lastBoundWitnessTime() -> UInt64?
}
