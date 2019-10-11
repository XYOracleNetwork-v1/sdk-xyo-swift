//
//  XyoBleClient.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

class XyoBleClient: XyoClient {
  var acceptBridging: Bool
  var autoBoundWitness: Bool
  var autoBridge: Bool
  
  init(autoBoundWitness: Bool, autoBridge: Bool, acceptBridging: Bool) {
    self.autoBoundWitness = autoBoundWitness
    self.autoBridge = autoBridge
    self.acceptBridging = acceptBridging
  }
  
  func initiateBoundWitness(device: XyoNetworkDevice, bridge: Bool) {
    
  }
}
