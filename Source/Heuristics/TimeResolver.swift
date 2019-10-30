//
//  TimeResolver.swift
//  sdk-xyo-swift
//
//  Created by Kevin Weiler on 10/28/19.
//

import Foundation
import sdk_objectmodel_swift

public struct TimeResolver: XyoHumanHeuristicResolver {
  public init() {
    
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
        formatter.dateFormat = "MM-dd-yyyy HH:mm"

        return formatter.string(from: NSDate(timeIntervalSince1970: Double(mills) / 1000) as Date)
    }
}
