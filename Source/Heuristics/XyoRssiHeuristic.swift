//
//  XyoRssiHeuristic.swift
//  sdk-xyo-swift
//
//  Created by Kevin Weiler on 11/12/19.
//

import Foundation
import sdk_core_swift

class XyoRssiHeuristic: XyoHeuristicGetter {
  public var rssi: Int?
  public init() {}
  public func getHeuristic() -> XyoObjectStructure? {
    guard let rss = rssi else { return nil }
    
    let unsignedRssi = UInt8(bitPattern: Int8(rss))
    let rssiTag = XyoObjectStructure.newInstance(schema: XyoSchemas.RSSI, bytes: XyoBuffer().put(bits: (unsignedRssi)))

    return rssiTag
  }
}
