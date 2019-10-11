//
//  XyoTcpipServer.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

class XyoTcpipServer: XyoServer {
  var autoBridge: Bool
  var acceptBridging: Bool
  
  internal init(autoBridge: Bool, acceptBridging: Bool, listen: Bool) {
    self.autoBridge = autoBridge
    self.acceptBridging = acceptBridging
    self.listen = listen
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
