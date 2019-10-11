//
//  XyoBleNetwork.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

class XyoBleNetwork: XyoNetwork {
  var client: XyoClient = XyoBleClient(autoBoundWitness: false, autoBridge: false, acceptBridging: false)
  var server: XyoServer = XyoBleServer(acceptBridging: false)
}
