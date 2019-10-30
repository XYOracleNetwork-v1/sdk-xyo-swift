//
//  XyoBlobData.swift
//  sdk-core-swift
//
//  Created by Kevin Weiler on 10/29/19.
//

import Foundation
import sdk_core_swift
import sdk_objectmodel_swift

public struct XyoString : XyoHeuristicGetter {
  private let bytes : [UInt8]
  
  public init(bytes : [UInt8]) {
    self.bytes = bytes
  }
    
  public func getHeuristic() -> XyoObjectStructure? {

    return XyoObjectStructure.newInstance(schema: XyoSchemas.BLOB, bytes: XyoBuffer.init(data: bytes))
  }
}
