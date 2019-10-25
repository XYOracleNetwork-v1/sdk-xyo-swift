//
//  XyoTcpipNetwork.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_core_swift

public class XyoTcpipNetwork: XyoNetwork {

  init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    super.init(_type: .tcpIp)

    client = XyoTcpipClient(relayNode: relayNode, procedureCatalog: procedureCatalog, autoBridge: true, acceptBridging: false, autoBoundWitness: true)
    
    server = XyoTcpipServer(relayNode: relayNode, procedureCatalog: procedureCatalog, autoBridge: true, acceptBridging: false)
    
    if (client?.knownBridges.count == 0) {
      client?.knownBridges.append("ws://alpha-peers.xyo.network:11000")
    }
    client?.scan = false
    server?.listen = false
    
  }
  deinit {
    print("Deallocing Tcpip Network")
  }
}

