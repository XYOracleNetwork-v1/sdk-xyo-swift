//
//  BlobDataResolver.swift
//  sdk-xyo-swift
//
//  Created by Kevin Weiler on 10/29/19.
//

import Foundation
import sdk_core_swift
import sdk_objectmodel_swift

public struct StringResolver: XyoHumanHeuristicResolver {
  
  public init () {}
    public func getHumanKey(partyIndex: Int) -> String {
        return String(format: NSLocalizedString("String %d", comment: "String heuristic key"), partyIndex)
    }

    public func getHumanName (object: XyoObjectStructure, partyIndex: Int) throws -> String? {
        let objectValue = try? object.getValueCopy()
      
      if let blob = objectValue?.toByteArray() {
        return  String(bytes: blob, encoding: .utf8)
      }
      return ""
    }
}

extension XyoBoundWitness {

  public func resolveString(forParty: Int) -> String {
  
    let resolver = StringResolver()
    XyoHumanHeuristics.resolvers[XyoSchemas.BLOB.id] = resolver
    
    let heuristics = XyoHumanHeuristics.getHumanHeuristics(boundWitness: self)
    
    let key = resolver.getHumanKey(partyIndex: forParty)
    return heuristics[key] ?? ""
  }
}
