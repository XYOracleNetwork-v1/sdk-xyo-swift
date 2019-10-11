//
//  XyoTcpipNetwork.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

class XyoTcpipNetwork: XyoNetwork {
  var client: XyoClient = XyoTcpipClient(autoBoundWitness: false, autoBridge: false, acceptBridging: false)
  var server: XyoServer = XyoTcpipServer(autoBridge: false, acceptBridging: false, listen: false)
}
