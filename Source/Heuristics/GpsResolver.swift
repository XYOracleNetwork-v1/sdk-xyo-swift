//
//  GpsResolver.swift
//  sdk-xyo-swift
//
//  Created by Kevin Weiler on 10/28/19.
//

import Foundation
import sdk_core_swift

public struct GpsResolver: XyoHumanHeuristicResolver {
    public init() {}

    public func getHumanKey(partyIndex: Int) -> String {
        return String(format: NSLocalizedString("GPS %d", comment: "gps value"), partyIndex)
    }

    public func getHumanName (object: XyoObjectStructure, partyIndex: Int) throws -> String? {
        guard let gps = object as? XyoIterableStructure else {
            return nil
        }

        guard let lat = try gps.get(objectId: XyoSchemas.LAT.id).first?.getValueCopy() else {
            return nil
        }

        guard let lng = try gps.get(objectId: XyoSchemas.LNG.id).first?.getValueCopy() else {
            return nil
        }

        if lng.getSize() != 8 || lat.getSize() != 8 {
            return nil
        }

        let latNumData = Double(bitPattern: lat.getUInt64(offset: 0))
        let lngNumData = Double(bitPattern: lng.getUInt64(offset: 0))

        return "\(latNumData), \(lngNumData)"
    }
}

extension XyoBoundWitness {
    public func resolveGPSPayload(forParty: Int) -> String? {
      let resolver = GpsResolver()
    XyoHumanHeuristics.resolvers[XyoSchemas.GPS.id] = resolver
      
      return resolver.getName(forParty: forParty, boundWitness: self)
    }
}

