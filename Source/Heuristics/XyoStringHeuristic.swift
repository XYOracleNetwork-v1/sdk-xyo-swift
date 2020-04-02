//
//  XyoBlobData.swift
//  sdk-core-swift
//
//  Created by Kevin Weiler on 10/29/19.
//

import Foundation
import sdk_core_swift

public struct XyoStringHeuristic : XyoHeuristicGetter {
  public let _getStringHeuristic : () -> String?
  public init(_ getStringHeuristic : @escaping () -> String?) {
    _getStringHeuristic = getStringHeuristic
  }
    
  public func getHeuristic() -> XyoObjectStructure? {
    guard let str = _getStringHeuristic() else {
      return nil
    }
    let bytes = [UInt8](str.utf8)
    return XyoObjectStructure.newInstance(schema: XyoSchemas.BLOB, bytes: XyoBuffer.init(data: bytes))
  }
}
