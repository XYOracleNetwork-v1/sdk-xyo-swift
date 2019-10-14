//
//  XyoNetwork.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
enum XyoNetworkType {
  case ble
  case tcp
  case other
}
protocol XyoNetwork {
  var type : XyoNetworkType { get }
  var client: XyoClient { get }
  var server: XyoServer { get }
}
