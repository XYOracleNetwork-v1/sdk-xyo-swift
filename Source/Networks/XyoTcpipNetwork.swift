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
  public var type: XyoNetworkType
  public var client: XyoClient
  public var server: XyoServer
  
  init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    type = .tcpIp

    client = XyoTcpipClient(relayNode: relayNode, procedureCatalog: procedureCatalog, autoBridge: true, acceptBridging: false, autoBoundWitness: true)
    
    server = XyoTcpipServer(relayNode: relayNode, procedureCatalog: procedureCatalog, autoBridge: true, acceptBridging: false)
    
    if (client.knownBridges == nil) {
      client.knownBridges = ["ws://alpha-peers.xyo.network:11000"]
    }
    client.scan = true
    server.listen = true
    
  }

}