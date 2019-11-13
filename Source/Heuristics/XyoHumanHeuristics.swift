//
//  XyoHumanHeuristics.swift
//  sdk-xyo-swift
//
//  Created by Kevin Weiler on 10/28/19.
//

import Foundation
import sdk_core_swift
import sdk_objectmodel_swift

extension XyoHumanHeuristicResolver {
  public func getName (forParty: Int, boundWitness: XyoBoundWitness) -> String? {
    let key = self.getHumanKey(partyIndex: forParty)

    let heuristics = XyoHumanHeuristics.getHumanHeuristics(boundWitness: boundWitness)
    
    return heuristics[key]
  }

}

public protocol XyoHumanHeuristicResolver {
  func getHumanKey (partyIndex: Int) -> String
  func getHumanName (object: XyoObjectStructure, partyIndex: Int) throws -> String?
  func getName (forParty: Int, boundWitness: XyoBoundWitness) -> String?
}

public struct XyoHumanHeuristics {
  public static var resolvers: [UInt8: XyoHumanHeuristicResolver] = [:]

  public static func getAllHeuristics (boundWitness: XyoBoundWitness) -> [String: String] {
    XyoHumanHeuristics.resolvers[XyoSchemas.GPS.id] = GpsResolver()
    XyoHumanHeuristics.resolvers[XyoSchemas.BLOB.id] = StringResolver()
    XyoHumanHeuristics.resolvers[XyoSchemas.UNIX_TIME.id] = TimeResolver()
    XyoHumanHeuristics.resolvers[XyoSchemas.RSSI.id] = RssiResolver()
    let heuristics = XyoHumanHeuristics.getHumanHeuristics(boundWitness: boundWitness)
    return heuristics
  }
  
  public static func getHumanHeuristics(boundWitness: XyoBoundWitness) -> [String: String] {
      do {
          var returnArray: [String: String] = [:]
          guard let numberOfParties = try boundWitness.getNumberOfParties() else {
              return [:]
          }

          if numberOfParties == 0 {
              return [:]
          }

          for i in 0...numberOfParties - 1 {
              guard let it = try boundWitness.getFetterOfParty(partyIndex: i)?.getNewIterator() else {
                  return [:]
              }

              while try it.hasNext() {
                  let payloadItem = try it.next()
                  let pays = try XyoHumanHeuristics.handleSinglePayloadItem(item: payloadItem, index: i)
                  if pays != nil {
                      returnArray[pays.unsafelyUnwrapped.0] = pays.unsafelyUnwrapped.1
                  }
              }
          }

          return returnArray
      } catch {
          return [:]
      }
  }

  private static func handleSinglePayloadItem (item: XyoObjectStructure, index: Int) throws -> (String, String)? {
      let idOfPayloadItem = try item.getSchema().id
      guard let resolver = resolvers[idOfPayloadItem] else {
          return nil
      }

      guard let value = try resolver.getHumanName(object: item, partyIndex: index) else {
          return nil
      }

      let key = resolver.getHumanKey(partyIndex: index)

      return (key, value)
  }
  
  
}




