//
//  XyoBleServer.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

class XyoBleServer: XyoServer {
  var acceptBridging: Bool
  
  init(acceptBridging: Bool) {
    self.acceptBridging = acceptBridging
  }
  
  var listen: Bool {
    get {
      return false //replace with server enabled state
    }
    set {
      //enable/disable server
    }
  }
}
