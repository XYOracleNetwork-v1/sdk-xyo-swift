//
//  XyoOriginChainState.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/// A call to manage an XyoOriginChainStateRepository such that when a origin block has been created,
/// it will update the repository to reflect the current root state of the node.
public class XyoOriginChainState {
    
    /// The repository that the origin state will talk to, to persist all of the data.
    public let repo : XyoOriginChainStateRepository
    
    /// The on deck signers to be added to after the next public key has gone inside of a bound witness.
    /// This array acts as a queue where the first element is the next key on deck.
    private var waitingSigners : [XyoSigner] = []
    
    /// This varable acts as a temporary state holder to put the next public key in the next bound witness.
    private var nextPublicKey : XyoObjectStructure? = nil
    
    /// Creates a new origin chain state object, that will use the repository
    /// - Parameter repository: The repository to send state change updates to.
    public init(repository : XyoOriginChainStateRepository) {
        self.repo = repository
    }

    /// Gets the index to include in the current bound witness
    /// - Returns: The previous index + 1, to include in the next bound witness
    public func getIndex () -> XyoObjectStructure {
        return repo.getIndex() ?? XyoOriginChainState.createIndex(index: 0)
    }
    
    /// Gets the previous hash to inlucde in the current bound witness.
    /// - Returns: The hash of the previous block, wrapped inside of a previous hash object, will
    /// return nil, if no block has been made yet.
    public func getPreviousHash () -> XyoObjectStructure? {
        return repo.getPreviousHash()
    }
    
    /// Returns the current signers to use inside of the next bound witness.
    /// - Returns: The signers to include in the next bound witness.
    public func getSigners () -> [XyoSigner] {
        return repo.getSigners()
    }
    
    /// Returns the next public key heuristic to include in the next bound witness if there
    /// is a signer on deck.
    /// - Returns: The next public key object to add in the next bound witness, will return nil if none.
    public func getNextPublicKey () -> XyoObjectStructure? {
        return nextPublicKey
    }
    
    /// Removes the oldest signer in the signer array, this function should be called when a user
    /// wants to rotate keys.
    public func removeOldestSigner () {
        repo.removeOldestSigner()
    }
    
    /// Adds a signer to the list of signers that can be obtained from getSigners()
    /// If the origin state has not made a block yet, the signer will go directly into the signers, else
    /// it will be added to next public key first. If you are trying to restore signer state, add to the
    /// repoisorty, not this function.
    /// - Parameter signer: The signer to add to the origin state.
    public func addSigner (signer : XyoSigner) {
        do {
            let index = try getIndex().getValueCopy().getUInt32(offset: 0)
            
            if (index == 0) {
                repo.putSigner(signer: signer)
                return
            }
        } catch {
            // this will only hit of the repository returns an invalid value.
            fatalError("Index should be parcable.")
        }
        
        waitingSigners.append(signer)
        nextPublicKey = XyoOriginChainState.createNextPublicKey(publicKey: signer.getPublicKey())
    }
    
    /// This function should be called every time a bound witness is completed, to update the state.
    /// The repository state should also be committed after this function is called.
    /// - Parameter hash: The hash of the bound witness to add to the origin state (this will become the previous hash).
    public func addOriginBlock (hash : XyoObjectStructure) {
        do {
            let previousHash = try XyoOriginChainState.createPreviousHash(hash: hash)
            nextPublicKey = nil
            addWaitingSigner()
            repo.putPreviousHash(hash: previousHash)
            incrementIndex()
            repo.onBoundWitness()
        } catch {
            // dont do anything if there is something wrong with the hash, this should never happen
            fatalError()
        }
    }
    
    
    /// This function takes the current index in the repository, adds 1, and then saves it to the repository.
    private func incrementIndex () {
        do {
            let index = try getIndex().getValueCopy().getUInt32(offset: 0)
            let awaitingIndex = XyoOriginChainState.createIndex(index: index + 1)
            repo.putIndex(index: awaitingIndex)
        } catch {
            fatalError("Index provided is invalid.")
        }
    }
    
    /// This function takes the current signer on deck from waitingSigners, and adds it to the primary list of signers.
    private func addWaitingSigner () {
        if (waitingSigners.count > 0) {
            repo.putSigner(signer: waitingSigners[0])
            waitingSigners.remove(at: 0)
        }
    }
    
    public func getStaticHeuristics () -> [XyoObjectStructure] {
        return self.repo.getStaticHeuristics()
    }
    
    /// This function creates an XYO index object from a UInt32.
    /// - Parameter index: The index to encode in the xyo index object.
    /// - Returns: The encoded index
    public static func createIndex (index : UInt32) -> XyoObjectStructure {
        let buffer = XyoBuffer()
        buffer.put(bits: index)
        return XyoObjectStructure.newInstance(schema: XyoSchemas.INDEX, bytes: buffer)
    }
    
    /// This function creates a xyo previous hash object from an xyo hash object
    /// - Parameter hash: The hash to put inside of the previous hash object.
    /// - Returns: The encoded previous hash object.
    public static func createPreviousHash (hash : XyoObjectStructure) throws -> XyoObjectStructure {
        return try XyoIterableStructure.createTypedIterableObject(schema: XyoSchemas.PREVIOUS_HASH, values: [hash])
    }
    
    /// This function creates an xyo next public key object from a public key.
    /// - Parameter publicKey: The public key to wrap in a next public key object.
    /// - Returns: The encoded next public key object from public key
    public static func createNextPublicKey (publicKey : XyoObjectStructure) -> XyoObjectStructure {
        return XyoObjectStructure.newInstance(schema: XyoSchemas.NEXT_PUBLIC_KEY, bytes: publicKey.getBuffer())
    }

}
