//
//  XyoTcpipClient.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_core_swift

class XyoTcpipClient: XyoClient {
  
  var knownBridges: [String]?
  var relayNode: XyoRelayNode
  var procedureCatalog: XyoProcedureCatalog
  weak var delegate: BoundWitnessDelegate?

  var acceptBridging: Bool = false
  var autoBridge: Bool = false
  var autoBoundWitness: Bool = false
  var scan: Bool = false
  
  required init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    self.procedureCatalog = procedureCatalog
    self.relayNode = relayNode
  }
  
  convenience init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog, autoBridge: Bool, acceptBridging: Bool, autoBoundWitness: Bool) {
    self.init(relayNode: relayNode, procedureCatalog: procedureCatalog)
    self.autoBridge = autoBridge
    self.acceptBridging = acceptBridging
    self.autoBoundWitness = autoBoundWitness
  }
  

}
