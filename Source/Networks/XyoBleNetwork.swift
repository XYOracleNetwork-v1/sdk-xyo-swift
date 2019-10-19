//
//  XyoBleNetwork.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_core_swift

public class XyoBleNetwork: XyoNetwork { 
  public var type: XyoNetworkType
  public var client: XyoClient
  public var server: XyoServer
  
  init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    type = .bluetoothLe
    
    client = XyoBleClient(relayNode: relayNode, procedureCatalog: procedureCatalog, autoBridge: false, acceptBridging: false, autoBoundWitness: true)
    
    server = XyoBleServer(relayNode: relayNode, procedureCatalog: procedureCatalog, autoBridge: false, acceptBridging: false)
    
    client.scan = true
    server.listen = true
  }

}
