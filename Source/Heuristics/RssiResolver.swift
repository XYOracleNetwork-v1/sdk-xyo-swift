//
//  RssiResolver.swift
//  sdk-xyo-swift
//
//  Created by Kevin Weiler on 10/28/19.
//

import Foundation
import sdk_core_swift
import sdk_objectmodel_swift

public struct RssiResolver: XyoHumanHeuristicResolver {
  public init() {}
  public func getHumanKey(partyIndex: Int) -> String {
        return String(format: NSLocalizedString("RSSI %d", comment: "rssi value"), partyIndex)
    }

  public func getHumanName (object: XyoObjectStructure, partyIndex: Int) throws -> String? {
        let objectValue = try object.getValueCopy()

        if objectValue.getSize() > 0 {
            let rssi = Int8(bitPattern: (objectValue.getUInt8(offset: 0)))

            return String(rssi)
        }

        return nil
    }
}

extension XyoBoundWitness {
    public func resolveRssiPayload(forParty: Int) -> String? {
      let resolver = RssiResolver()
    XyoHumanHeuristics.resolvers[XyoSchemas.RSSI.id] = resolver
      
      return resolver.getName(forParty: forParty, boundWitness: self)
    }
}
