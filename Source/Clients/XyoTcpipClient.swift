//
//  XyoTcpipClient.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

class XyoTcpipClient: XyoClient {
  var acceptBridging: Bool
  var autoBridge: Bool
  
  init(autoBoundWitness: Bool, autoBridge: Bool, acceptBridging: Bool) {
    self.autoBridge = autoBridge
    self.acceptBridging = acceptBridging
    self.autoBoundWitness = autoBoundWitness
  }
  
  var autoBoundWitness: Bool {
    get {
      return false //replace with auto enabled state
    }
    set {
      //enable/disable auto
    }
  }
  
  func initiateBoundWitness(device: XyoNetworkDevice, bridge: Bool) {
    
  }
}
