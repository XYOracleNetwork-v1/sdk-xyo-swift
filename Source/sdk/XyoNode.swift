//
//  XyoNode.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_core_swift

public class XyoNode {
  public var networks: [String: XyoNetwork]
  public let storage: XyoStorageProvider
  
  internal init(storage: XyoStorageProvider, networks: [String: XyoNetwork]) {
    self.storage = storage
    
    self.networks = networks
  }
  
  func setAllDelegates(delegate: BoundWitnessDelegate) {
    for (key, _) in networks {
      networks[key]?.client.delegate = delegate
      networks[key]?.server.delegate = delegate
    }
  }
}
