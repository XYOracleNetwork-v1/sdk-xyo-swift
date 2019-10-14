//
//  XyoNode.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

class XyoNode {
  public let networks: [String: XyoNetwork]
  public let storage: XyoStorage
  
  internal init(storage: XyoStorage, networks: [String: XyoNetwork]) {
    self.storage = storage
    
    self.networks = networks
  }
}
