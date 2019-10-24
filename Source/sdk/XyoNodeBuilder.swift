//
//  XyoNodeBuilder.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_core_swift
import sdk_xyobleinterface_swift

struct XyoNodeBuilderError : Error {
  enum ErrorKind {
    case alreadyNodes
  }
  let kind: ErrorKind
}

public class XyoNodeBuilder {
  public init() {}
  private var networks = [String: XyoNetwork]()
  private var storage: XyoStorageProvider?
  private var relayNode: XyoRelayNode?
  private var procedureCatalog: XyoProcedureCatalog?
  private var hashingProvider: XyoHasher?
  private var stateRepository: XyoOriginChainStateRepository?
  private var bridgeQueueRepository: XyoStorageBridgeQueueRepository?
  private var blockRepository: XyoStorageProviderOriginBlockRepository?

  weak private var delegate: BoundWitnessDelegate?
  
  public func addNetwork(name: String, _ network: XyoNetwork) {
    networks[name] = network
  }
  
  public func setStorage(_ storage: XyoStorageProvider) {
    self.storage = storage
  }
  
  public func setBoundWitnessDelegate(_ delegate: BoundWitnessDelegate) {
    self.delegate = delegate
  }
  
  deinit {
    print("Deallocing XYO Builder")
    networks.removeAll()
//    relayNode = nil
//    storage = nil
//    blockRepository = nil
//    procedureCatalog = nil
//    hashingProvider = nil
//    bridgeQueueRepository = nil
//    stateRepository = nil
  }
  
  public func build() throws -> XyoNode {
    if (XyoSdk.nodes.count > 0) {
      throw XyoNodeBuilderError(kind: .alreadyNodes)
    }
    if (self.storage == nil) {
      setDefaultStorage()
    }
    
    if (hashingProvider == nil) {
        print("No hashingProvider specified, using default")
        setDefaultHashingProvider()
    }

    if (blockRepository == nil) {
        print("No blockRepository specified, using default")
        setDefaultBlockRepository()
    }

    if (stateRepository == nil) {
        print("No stateRepository specified, using default")
        setDefaultStateRepository()
    }

    if (bridgeQueueRepository == nil) {
        print("No bridgeQueueRepository specified, using default")
        setDefaultBridgeQueueRepository()
    }

    if (procedureCatalog == nil) {
        print("No procedureCatalog specified, using default")
        setDefaultProcedureCatalog()
    }

    if (relayNode == nil) {
        print("No relayNode specified, using default")
        setDefaultRelayNode()
    }

    if (networks.count == 0) {
      setDefaultNetworks()
    }
    
    let node = XyoNode(storage: storage!, _networks: networks)
    XyoSdk.nodes.append(node)
    if let d = delegate {
      node.setAllDelegates(delegate: d)
    }
    
    return node
  }
  
  private func setDefaultProcedureCatalog() {
    let canDoByte = XyoProcedureCatalogFlags.BOUND_WITNESS | XyoProcedureCatalogFlags.GIVE_ORIGIN_CHAIN | XyoProcedureCatalogFlags.TAKE_ORIGIN_CHAIN
    
    procedureCatalog = XyoFlagProcedureCatalog(forOther: UInt32(canDoByte), withOther: UInt32(canDoByte))
          
  }
  
  private func setDefaultStateRepository() {
    if let st = storage {
      stateRepository = XyoStorageOriginStateRepository(storage: st)
        return
      }
      print("Missing storage")
  }
  
  private func setDefaultBlockRepository() {
    if let st = storage {
      if let hash = hashingProvider {
        blockRepository = XyoStorageProviderOriginBlockRepository(storageProvider: st, hasher: hash)
              return
          }
          print("Missing hashingProvider")
          return
      }
      print("Missing storage")
  }

  private func setDefaultHashingProvider() {
      hashingProvider = XyoSha256()
  }
  
  private func setDefaultBridgeQueueRepository() {
    if let st = storage {
      bridgeQueueRepository = XyoStorageBridgeQueueRepository(storage: st)
          return
      }
      print("Missing storage")
  }
  
  private func setDefaultRelayNode() {
    if let br = blockRepository {
      if let sr = stateRepository {
        if let bq = bridgeQueueRepository {
          if let hp = hashingProvider {
            let repositoryConfiguration = XyoRepositoryConfiguration(originState: sr, originBlock: br)
              relayNode = XyoRelayNode(
                hasher: hp,
                repositoryConfiguration: repositoryConfiguration,
                queueRepository: bq
              )
              return
          }
          print("Missing hashingProvider")
          return
        }
        print("Missing bridgeQueueRepository")
        return
      }
      print("Missing stateRepository")
      return
    }
    print("Missing blockRepository")
  }
  
  private func setDefaultNetworks() {
    if let rn = relayNode {
      if let pc = procedureCatalog {
        addNetwork(name: "ble", XyoBleNetwork(relayNode: rn, procedureCatalog: pc))
        addNetwork(name: "tcpip", XyoTcpipNetwork(relayNode: rn, procedureCatalog: pc))
        return
      }
      print("Missing procedure catalog")
      return
    }
    print("Missing relay node")
  }
  
  private func setDefaultStorage() {
    storage = XyoInMemoryStorage()
  }
}



