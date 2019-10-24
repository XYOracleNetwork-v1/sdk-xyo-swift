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

public protocol BoundWitnessDelegate : AnyObject {
  // Retrieves client data to pass in a bound witness
  func getPayloadData() -> [UInt8]?

  func boundWitness(started withDeviceId: String)
  func boundWitness(completed withDeviceId: String, withBoundWitness: XyoBoundWitness?)
  func boundWitness(failed withDeviceId: String?, withError: XyoError)
}

public protocol XyoBoundWitnessTarget {
  //accept boundwitnesses that have bridges payloads
  var acceptBridging: Bool { get set }

  //when auto boundwitnessing, should we bridge our chain
  var autoBridge: Bool {get set}
  
  var delegate: BoundWitnessDelegate? { get set }

  var relayNode: XyoRelayNode { get }
  
  var procedureCatalog: XyoProcedureCatalog {get}
  
  init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog)
  
  func publicKey() -> String?
}

extension XyoBoundWitnessTarget {
  func publicKey() -> String? {
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
  func getPayloadData() -> [UInt8]? {
    return nil
  }

  func boundWitness(didStart withDevice: XyoBoundWitnessTarget) { print("Bound Witness Started") }
  func boundWitness(completed withBoundWitness: XyoBoundWitness, withDevice: XyoBoundWitnessTarget) { print("Bound Witness Completed")  }
  func boundWitness(failed withError: XyoError) { print("Bound Witness Failed")  }
}
