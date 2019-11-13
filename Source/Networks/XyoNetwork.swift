//
//  XyoNetwork.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

import sdk_core_swift

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
    client?.disableHeuristics()
    server?.disableHeuristics()
    // Make them hold weak references to the heuristics delegates and listeners so we don't have to clean up here
    client?.relayNode.removeListener(key: "RELAY_NODE")
    server?.relayNode.removeListener(key: "RELAY_NODE")
  }
}

