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

protocol BoundWitnessDelegate {
    func boundWitness(didStart withDevice: XYBluetoothDevice)
    func boundWitness(didComplete withBoundWitness: BoundWitnessParseable, withDevice: XYBluetoothDevice)
    func boundWitness(didFail withError: Error)
}


protocol XyoBoundWitnessTarget {
  //accept boundwitnesses that have bridges payloads
  var acceptBridging: Bool { get set }

  //when auto boundwitnessing, should we bridge our chain
  var autoBridge: Bool {get set}
  
  var delegate: BoundWitnessDelegate? { get set }

  var relayNode: XyoRelayNode { get }
  
  var procedureCatalog: XyoProcedureCatalog {get}
  
  init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog)
}

extension BoundWitnessDelegate {
  func boundWitness(didStart withDevice: XYBluetoothDevice) { print("Bound Witness Started") }
  func boundWitness(didComplete withBoundWitness: BoundWitnessParseable, withDevice: XYBluetoothDevice) { print("Bound Witness Completed")  }
  func boundWitness(didFail withError: Error) { print("Bound Witness Failed")  }
}
