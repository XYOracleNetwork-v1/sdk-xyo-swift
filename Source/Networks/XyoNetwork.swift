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
public protocol XyoNetwork {
  var type : XyoNetworkType { get }
  var client: XyoClient { get set }
  var server: XyoServer { get set }
}
