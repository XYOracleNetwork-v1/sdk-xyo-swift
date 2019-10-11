//
//  XyoSdk.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation

enum XyoSdkError: Error {
    case tooManyNodes
}

class XyoSdk {
  private init() {}
  
  //I am usiug an array here to support future multiple nodes
  static public var nodes = [XyoNode]()
}
