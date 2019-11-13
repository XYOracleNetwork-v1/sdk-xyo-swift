//
//  TimeResolver.swift
//  sdk-xyo-swift
//
//  Created by Kevin Weiler on 10/28/19.
//

import Foundation
import sdk_core_swift
import sdk_objectmodel_swift

public struct TimeResolver: XyoHumanHeuristicResolver {
  private let dateFormat : String
  public init(format :String = "MM-dd-yyyy HH:mm") {
    dateFormat = format
  }
    public func getHumanKey(partyIndex: Int) -> String {
        return String(format: NSLocalizedString("Time %d", comment: "time value"), partyIndex)
    }

    public func getHumanName (object: XyoObjectStructure, partyIndex: Int) throws -> String? {
        let objectValue = try object.getValueCopy()

        if objectValue.getSize() != 8 {
            return nil
        }

        let mills = objectValue.getUInt64(offset: 0)
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat

        return formatter.string(from: NSDate(timeIntervalSince1970: Double(mills) / 1000) as Date)
    }
}

extension XyoBoundWitness {
  public func resolveTime(forParty: Int) -> String? {
    let resolver = TimeResolver()
    XyoHumanHeuristics.resolvers[XyoSchemas.UNIX_TIME.id] = resolver
    return resolver.getName(forParty: forParty, boundWitness: self)
  }
}
