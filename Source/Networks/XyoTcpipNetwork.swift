//
//  XyoTcpipNetwork.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_core_swift

class XyoTcpipNetwork: XyoNetwork {
  var type: XyoNetworkType
  
  init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    type = .tcp
    client = XyoBleClient(relayNode: relayNode, procedureCatalog: procedureCatalog)
    server = XyoBleServer(relayNode: relayNode, procedureCatalog: procedureCatalog)
  }
  var client: XyoClient
  var server: XyoServer
}
