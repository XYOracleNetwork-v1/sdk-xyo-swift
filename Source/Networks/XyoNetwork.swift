//
//  XyoNetwork.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
public enum XyoNetworkType {
  case bluetoothLe
  case tcpIp
  case other
}
public class XyoNetwork {
  public var type : XyoNetworkType
  public var client : XyoClient?
  public var server : XyoServer?
  init(_type: XyoNetworkType) {
    type = _type
  }
  deinit {
    print("Deallocing Xyo Network")
    client?.scan = false
    server?.listen = false
    // TODO fix the retain cycles in relay node
    // Make them hold weak references to the heuristics delegates and listeners so we don't have to clean up here
    client?.relayNode.removeListeners()
    client?.relayNode.removeHeuristics()
    server?.relayNode.removeListeners()
    server?.relayNode.removeHeuristics()
  }
}

