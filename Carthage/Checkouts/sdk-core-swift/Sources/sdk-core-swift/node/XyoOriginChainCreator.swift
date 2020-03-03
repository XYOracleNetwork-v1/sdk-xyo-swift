//
//  XyoOriginChainCreator.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/// This class acts as a the main entry point for creating and maintaining an origin chain.
open class XyoOriginChainCreator {
    
    /// The repository configuration that the origin chain creator will use to perisit state.
    public let repositoryConfiguration : XyoRepositoryConfiguration
    
    /// The hasher to use when hashing origin blocks.
    public let hasher : XyoHasher
    
    /// All of the heuristic getters to include inside of bound witnesses that this node will create.
    private var heuristics = [String : XyoHeuristicGetter]()
    
    /// All of the listeners to notify whenever a change has happened inside of the node.
    private var listeners = [String : XyoNodeListener]()
    
    /// All of the bound witness options that the node can handle when doing a bound witness.
    private var boundWitnessOptions = [String : XyoBoundWitnessOption]()
    
    /// The current bound witness that is being created.
    private var currentBoundWitnessSession : XyoZigZagBoundWitnessSession? = nil
    
    /// The origin state of the node. This contains index, previous hash, and signers. This will be called whenever
    /// a bound witness is created.
    public lazy var originState = XyoOriginChainState(repository: self.repositoryConfiguration.originState)
    
    /// Creates a new instance of an origin chain creator
    /// - Parameter hasher: The hasher to use when hashing bound witnesses.
    /// - Parameter repositoryConfiguration: The repositories to use when persisting state.
    public init(hasher : XyoHasher, repositoryConfiguration: XyoRepositoryConfiguration) {
        self.hasher = hasher
        self.repositoryConfiguration = repositoryConfiguration
    }
    
    /// Adds a heuristic to the map of heuristic creaters to include in every bound witness.
    /// - Parameter key: The key of the heuristic to add
    /// - Parameter getter: The object that will return a new heuristic for each bound witness.
    public func addHeuristic (key: String, getter : XyoHeuristicGetter) {
        heuristics[key] = getter
    }
    
    /// Removes the heuristic getter from the queue of possible heuristics by its key
    /// - Parameter key: The key of the heuristic to remove.
    public func removeHeuristic (key: String) {
        heuristics.removeValue(forKey: key)
    }
    
    /// Adds a listener to receive all node related callbacks. Note, when callbacks are called, they are blocking.
    /// - Parameter key: The key of the listener so that it can be retrived in the future.
    /// - Parameter listener: The listener to notify of events.
    public func addListener (key: String, listener : XyoNodeListener) {
        listeners[key] = listener
    }
    
    /// Removes a listner by its respected string.
    /// - Parameter key: The key of the lisitener to remove.
    public func removeListener (key: String) {
        listeners.removeValue(forKey: key)
    }
    
    /// Adds a bound witness option to the node by a key string.
    /// - Parameter key: The key of the bound witness option.
    /// - Parameter option: The bound witness option to add to the node.
    public func addBoundWitnessOption (key : String, option : XyoBoundWitnessOption) {
        boundWitnessOptions[key] = option
    }
    
    /// Removes a bound witness option by its key string.
    /// - Parameter key: The key of the bound witness option to remove.
    public func removeBoundWitnessOption (key: String) {
        boundWitnessOptions.removeValue(forKey: key)
    }
    
    /// Self signs the node's origin chain, will call back to the onBoundWitnessCompleted callback listener when done.
    /// This function will only throw if there is something invalid in the statics in originState
    public func selfSignOriginChain () throws {
        if (currentBoundWitnessSession == nil) {
            let additional = try getAdditionalPayloads(flag: [], pipe: nil)
            
            onBoundWitnessStart()
            let boundWitness = try XyoZigZagBoundWitness(signers: originState.getSigners(),
                                                         signedPayload: try makeSignedPayload(additional: additional.signedPayload),
                                                         unsignedPayload: additional.unsignedPayload)
            _ = try boundWitness.incomingData(transfer: nil, endpoint: true)
            
            try onBoundWitnessCompleted(boundWitness: boundWitness)
            return
        }
        
        throw XyoError.BW_IS_IN_PROGRESS
    }
    
    /// This is the most significant function in the node. It allows for the creation of bound witnesses. This is the
    /// primary bound witness access point besides selfSignOriginChain()
    /// - Parameter handler: The network handler to talk to the other node with. (it's a pipe helper)
    /// - Parameter procedureCatalogue: The catalogue to respect when creating a bound witness.
    /// - Parameter completion: The completion to call when the bound witness has been completed.
    public func boundWitness (handler : XyoNetworkHandler,
                              procedureCatalogue: XyoProcedureCatalog,
                              completion: @escaping (_: XyoBoundWitness?, _: XyoError?)->()) {
        
        if (currentBoundWitnessSession != nil) {
            completion(nil, XyoError.BW_IS_IN_PROGRESS)
            return
        }
        
        onBoundWitnessStart()
        
        if (handler.pipe.getInitiationData() == nil) {
            // is client
            
            // send first negotiation, response is their choice
            handler.sendCataloguePacket(catalogue: procedureCatalogue.getEncodedCatalogue()) { result in
                guard let responseWithTheirChoice = result else {
                    self.onBoundWitnessFailure()
                    completion(nil, XyoError.UNKNOWN_ERROR)
                    return
                }
                
                do {
                    let adv = XyoChoicePacket(data: responseWithTheirChoice)
                    let startingData = XyoIterableStructure(value: XyoBuffer(data: try adv.getResponse()))
                    let choice = try adv.getChoice()
                    self.doBoundWitnessWithPipe(startingData: startingData, handler: handler, choice: choice, completion: completion)
                } catch {
                    completion(nil, XyoError.UNKNOWN_ERROR)
                    return
                }
            }
            return
        }
        
        // is server, initation data is the client's catalogue, so we must choose one
        do {
            let choice = procedureCatalogue.choose(catalogue: try handler.pipe.getInitiationData().unsafelyUnwrapped.getChoice())
            doBoundWitnessWithPipe(startingData: nil, handler: handler, choice: XyoProcedureCatalogFlags.flip(flags: choice), completion: completion)
        } catch {
            completion(nil, XyoError.UNKNOWN_ERROR)
        }
    }
    
    /// This function performs a bound witness after the negotiation has been handled.
    /// - Parameter startingData: The first data that was received through the pipe, only if you act as a client.
    /// - Parameter handler: The network handler to communicate with the other peer for.
    /// - Parameter choice: The choice of the bound witness.
    /// - Parameter completion: The completion to call when the bound witness has been completed.
    private func doBoundWitnessWithPipe (startingData : XyoIterableStructure?, handler : XyoNetworkHandler, choice : [UInt8], completion: @escaping (_: XyoBoundWitness?, _: XyoError?)->()) {
    
        do {
            let options = getBoundWitnessesOptionsForFlag(flag: choice)
            let additional = try getAdditionalPayloads(flag: choice, pipe: handler.pipe)
            let boundWitness = try XyoZigZagBoundWitnessSession(signers: originState.getSigners(),
                                                                signedPayload: try makeSignedPayload(additional: additional.signedPayload),
                                                                unsignedPayload: additional.unsignedPayload,
                                                                handler: handler,
                                                                choice: XyoProcedureCatalogFlags.flip(flags: choice))
            
            currentBoundWitnessSession = boundWitness
            boundWitness.doBoundWitness(transfer: startingData) { result in
            
                do {
                    if (try boundWitness.getIsCompleted() == true) {
                        
                        if (options.count > 0) {
                            for i in 0...options.count - 1 {
                                options[i].onCompleted(boundWitness: boundWitness)
                            }
                        }
                        
                        try self.onBoundWitnessCompleted(boundWitness: boundWitness)
                    } else {
                        self.currentBoundWitnessSession = nil
                        completion(boundWitness, XyoError.UNKNOWN_ERROR)
                        return nil
                    }
                    
                    self.currentBoundWitnessSession = nil
                    completion(boundWitness, nil)
                } catch {
                    self.onBoundWitnessFailure()
                    handler.pipe.close()
                    self.currentBoundWitnessSession = nil
                    completion(nil, XyoError.UNKNOWN_ERROR)
                }
                
                handler.pipe.close()
                return nil
            }
            
        } catch {
            onBoundWitnessFailure()
            handler.pipe.close()
            currentBoundWitnessSession = nil
            completion(nil, XyoError.UNKNOWN_ERROR)
        }
    }
    
    /// This function should be called whenever a bound witness has started.
    private func onBoundWitnessStart () {
        for listener in listeners.values {
            listener.onBoundWitnessStart()
        }
    }
    
    /// This function should be called whenever a bound witness has failed.
    private func onBoundWitnessFailure () {
        for listener in listeners.values {
            listener.onBoundWitnessEndFailure()
        }
    }
    
    /// This function should be called only when a new bound witness has been completed sucssfully.
    /// - Parameter boundWitness: The bound witness that just got completed.
    private func onBoundWitnessCompleted (boundWitness : XyoBoundWitness) throws {
        try updateOriginState(boundWitness: boundWitness)
        try unpackBoundWitness(boundWitness: boundWitness)
        
        for listener in listeners.values {
            listener.onBoundWitnessEndSuccess(boundWitness: boundWitness)
        }
    }
    
    /// This function gets all of the bound witness options and heuristics to add to an upcoming bound witness.
    /// This function is called before every bound witness.
    /// - Parameter flag: The choice of the bound witness to get the payloads from.
    /// - Returns: Returns a all of the bound witness options for a new bound witness.
    private func getAdditionalPayloads (flag : [UInt8], pipe: XyoNetworkPipe?) throws -> XyoBoundWitnessHeuristicPair {
        let options = getBoundWitnessesOptionsForFlag(flag: flag)
        let optionPayloads = try getBoundWitnessesOptions(options: options)
        let hueresticPayloads = getAllHeuristics()
        
        var signedAdditional = [XyoObjectStructure]()
        var unsignedAdditional = [XyoObjectStructure]()
        
        signedAdditional.append(contentsOf: optionPayloads.signedPayload)
        signedAdditional.append(contentsOf: hueresticPayloads.signedPayload)
        
        signedAdditional.append(contentsOf: pipe?.getNetworkHeuristics() ?? [])
        unsignedAdditional.append(contentsOf: optionPayloads.unsignedPayload)
        unsignedAdditional.append(contentsOf: hueresticPayloads.unsignedPayload)
        
        return XyoBoundWitnessHeuristicPair(signedPayload: signedAdditional, unsignedPayload: unsignedAdditional)
    }
    
    /// This function unpacks a bound witness in a recursive manner and adds new blocks to the origin block repository,
    /// otherwise known as the de-onioner ;).
    /// - Parameter boundWitness: The bound witness to unpack.
    private func unpackBoundWitness (boundWitness : XyoBoundWitness) throws {
        let hash = try boundWitness.getHash(hasher: hasher)

        if (try !repositoryConfiguration.originBlock.containsOriginBlock(originBlockHash: hash.getBuffer().toByteArray())) {
            try unpackNewBoundWitness(boundWitness: boundWitness)
        }
    }
    
    /// This function unpacks a block that is not in the block reposiotry, and will filter all bridged blocks found to unpackBoundWitness()
    /// this is a recursive cycle.
    /// - Parameter boundWitness: A new bound witness to unpack.
    private func unpackNewBoundWitness (boundWitness : XyoBoundWitness) throws {
        let subblocks = try XyoOriginBoundWitnessUtil.getBridgedBlocks(boundWitness: boundWitness)
        let boundWitnessWithoughtSubBlocks = try XyoBoundWitnessUtil.removeIdFromUnsignedPayload(id: XyoSchemas.BRIDGE_BLOCK_SET.id,
                                                                                                 boundWitness: boundWitness)
        try repositoryConfiguration.originBlock.addOriginBlock(originBlock: boundWitnessWithoughtSubBlocks)
        
        for listener in listeners.values {
            listener.onBoundWitnessDiscovered(boundWitness: boundWitnessWithoughtSubBlocks)
        }
        
        if (subblocks != nil) {
            let it = try subblocks.unsafelyUnwrapped.getNewIterator()
            
            while (try it.hasNext()) {
                let item = try it.next().getBuffer()
                try unpackBoundWitness(boundWitness: XyoBoundWitness(value: item))
            }
        }
    }
    
    /// Updates the origin state of the node for a bound witness
    /// - Parameter boundWitness: The bound witness to get the hash of to add to the origin state.
    private func updateOriginState (boundWitness : XyoBoundWitness) throws {
        let hash = try boundWitness.getHash(hasher: hasher)
        originState.addOriginBlock(hash: hash)
    }
    
    /// This function gets all of the heuristics from all of the heuristic getters to add to a bound witenss
    /// - Returns: All of the heuristics to add to a bound witness.
    private func getAllHeuristics () -> XyoBoundWitnessHeuristicPair {
        var returnHuerestics = [XyoObjectStructure]()
        
        for getter in heuristics.values {
            let huerestic = getter.getHeuristic()
            
            if (huerestic != nil) {
                returnHuerestics.append(huerestic.unsafelyUnwrapped)
            }
        }
        
        return XyoBoundWitnessHeuristicPair(signedPayload: returnHuerestics, unsignedPayload: [])
    }
    
    /// This function makes an array of objects to include inside of the signed payload, this includes
    /// the previous hash index, and next public key. Also along with additional payloads.
    /// - Parameter additional: The other heuristics to add to signed payload.
    /// - Returns: An array of eveything to include inside of the bound witness.
    private func makeSignedPayload (additional : [XyoObjectStructure]) throws -> [XyoObjectStructure] {
        var signedPayload = additional
        let previousHash = originState.getPreviousHash()
        let index = originState.getIndex()
        let nextPublicKey = originState.getNextPublicKey()
        let statics = originState.getStaticHeuristics()
        
        if (previousHash != nil) {
            signedPayload.append(previousHash.unsafelyUnwrapped)
        }
        
        if (nextPublicKey != nil) {
            signedPayload.append(nextPublicKey.unsafelyUnwrapped)
        }
        
        signedPayload.append(index)
        signedPayload.append(contentsOf: statics)
        
        return signedPayload
    }
    
    /// This function gets all of the bound witness options for a particular flag
    /// - Parameter flag: The flag to check bound witness options for
    /// - Returns: All of the options that have that flag set
    private func getBoundWitnessesOptionsForFlag (flag : [UInt8]) -> [XyoBoundWitnessOption] {
        var retunOptions = [XyoBoundWitnessOption]()
        
        for option in boundWitnessOptions.values {
            if (min(option.getFlag().count, flag.count) != 0) {
                for i in 0...(min(option.getFlag().count, flag.count) - 1) {
                    let otherCatalogueSection = option.getFlag()[option.getFlag().count - i - 1]
                    let thisCatalogueSection = flag[flag.count - i - 1]
                    
                    if (otherCatalogueSection & thisCatalogueSection != 0) {
                        retunOptions.append(option)
                    }
                }
            }
        }
        
        return retunOptions
    }
    
    /// This function loops over all of the options obtained from getBoundWitnessesOptionsForFlag(), and returns
    /// all of the heuristics that those options have
    /// - Parameter options: The options to get the heuristics from
    /// - Returns: All of the heuristics contained in the options
    private func getBoundWitnessesOptions (options : [XyoBoundWitnessOption]) throws -> XyoBoundWitnessHeuristicPair {
        var signedPayloads = [XyoObjectStructure]()
        var unsignedPayloads = [XyoObjectStructure]()
        
        for option in options {
            let pair = try option.getPair()
            
            if (pair != nil) {
                signedPayloads.append(contentsOf: pair.unsafelyUnwrapped.signedPayload)
                unsignedPayloads.append(contentsOf: pair.unsafelyUnwrapped.unsignedPayload)
            }
        }
        
        return XyoBoundWitnessHeuristicPair(signedPayload: signedPayloads, unsignedPayload: unsignedPayloads)
    }
}
