//
//  XyoNode.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

class XyoNode {
  public let networks: [XyoNetwork]
  public let storage: XyoStorage
  
  internal init(storage: XyoStorage, networks: [XyoNetwork]) {
    self.storage = storage
    self.networks = networks
  }
}
