//
//  XyoBoundWitnessTarget.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift
import sdk_core_swift
import XyBleSdk

public enum XyoHeuristicEnum: String {
  case string, gps, time
}

public protocol BoundWitnessDelegate : AnyObject {
  func boundWitness(started withDeviceId: String)
  func boundWitness(completed withDeviceId: String, withBoundWitness: XyoBoundWitness?)
  func boundWitness(failed withDeviceId: String?, withError: XyoError)
}

public protocol XyoBoundWitnessTarget : AnyObject, XyoStringHueuristicDelegate {
  
  init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog)
  
  // callbacks on bound witness events
  var delegate: BoundWitnessDelegate? { get set }

  // accept boundwitnesses that have bridges payloads
  var acceptBridging: Bool { get set }

  //when auto boundwitnessing, should we bridge our chain
  var autoBridge: Bool {get set}
  
  // wrap this shared node
  var relayNode: XyoRelayNode { get }
  
  // configuration for this bound witness node
  var procedureCatalog: XyoProcedureCatalog {get}
  
  // the public address for this node's origin chain
  func publicKey() -> String?
  
  // enable heuristics for given type
  func enableHeursitics(heuristics: [XyoHeuristicEnum], enabled: Bool)
  
  // to be called in on deinit until we use weak reference array on heuristic getters
  func disableHeuristics()
  
  // dict of the heuristic fetcher wrappers
  var enabledHeuristics: [XyoHeuristicEnum: XyoHeuristicGetter] { get set }
}

public protocol XyoStringHueuristicDelegate {
  // set this to control dynamic string heuristic on a node
  var stringHeuristic: String? { get set }
  
  // allows fetching of heuristic from the XyoHeuristicGetter
  func getStringHeuristic() ->  String?
}

extension XyoBoundWitnessTarget {

  func getStringHeuristic() ->  String? {
    return stringHeuristic
  }

   func disableHeuristics() {
    enableHeursitics(heuristics: Array(enabledHeuristics.keys), enabled: false)
  }
  
  
   func enableHeursitics(heuristics: [XyoHeuristicEnum], enabled: Bool) {
    for heuristic in heuristics {
      let heuristicName = heuristic.rawValue + String(describing: self)
      if enabled {
        switch heuristic {
        case .gps:
          enabledHeuristics[heuristic] = XyoGpsHeuristic()
          break
        case .string:
          enabledHeuristics[heuristic] = XyoStringHeuristic(getStringHeuristic)
          break
        case .time:
          enabledHeuristics[heuristic] = XyoUnixTimeHeuristic()
          break
        }
        relayNode.addHeuristic(key: heuristicName, getter: enabledHeuristics[heuristic]!)

      } else {
        enabledHeuristics.removeValue(forKey: heuristic)
        relayNode.removeHeuristic(key: heuristicName)
      }
    }
    
  }
  
  public func publicKey() -> String? {
    if (relayNode.originState.getSigners().count == 0) {
        return nil
    }
    guard let bytes = relayNode.originState.getSigners().first?.getPublicKey().getBuffer().toByteArray() else {
      return nil
    }
    return bytes.toBase58String()
  }
}

extension BoundWitnessDelegate {
  func boundWitness(didStart withDevice: XyoBoundWitnessTarget) { print("Bound Witness Started") }
  func boundWitness(completed withBoundWitness: XyoBoundWitness, withDevice: XyoBoundWitnessTarget) { print("Bound Witness Completed")  }
  func boundWitness(failed withDeviceId: String?, withError: XyoError) {
    print("Bound Witness Failed \(withError)")

  }
}
