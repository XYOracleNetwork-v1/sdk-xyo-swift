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
  
  init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    super.init(_type: .bluetoothLe)
    
    client = XyoBleClient(relayNode: relayNode, procedureCatalog: procedureCatalog, autoBridge: false, acceptBridging: false, autoBoundWitness: true)
    
    server = XyoBleServer(relayNode: relayNode, procedureCatalog: procedureCatalog, autoBridge: false, acceptBridging: false)

  }
  
  deinit {
    print("Deallocing BLE Network")
  }

}


