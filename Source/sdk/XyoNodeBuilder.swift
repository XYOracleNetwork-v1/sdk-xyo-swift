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

class XyoNodeBuilder {
  init() {}
  private var networks = [String: XyoNetwork]()
  private var storage: XyoStorage?
  private var relayNode: XyoRelayNode?
  private var procedureCatalog: XyoProcedureCatalog?
  
  public func addNetwork(name: String, _ network: XyoNetwork) {
    networks[name] = network
  }
  
  public func setStorage(_ storage: XyoStorage) {
    self.storage = storage
  }
  
  public func build() throws -> XyoNode {
    if (XyoSdk.nodes.count > 0) {
      throw XyoSdkError.tooManyNodes
    }
    
    if (networks.count == 0) {
      setDefaultNetworks()
    }
    
    if (self.storage == nil) {
      setDefaultStorage()
    }
    
    let node = XyoNode(storage: storage!, networks: networks)
    XyoSdk.nodes.append(node)
    return node
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
    setStorage(XyoStorage())
  }
}



