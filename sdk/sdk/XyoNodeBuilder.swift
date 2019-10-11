//
//  XyoNodeBuilder.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

class XyoNodeBuilder {
  init() {}
  private var networks = [XyoNetwork]()
  private var storage: XyoStorage?
  
  public func addNetwork(_ network: XyoNetwork) {
    networks.append(network)
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
    addNetwork(XyoBleNetwork())
    addNetwork(XyoTcpipNetwork())
  }
  
  private func setDefaultStorage() {
    setStorage(XyoStorage())
  }
}
