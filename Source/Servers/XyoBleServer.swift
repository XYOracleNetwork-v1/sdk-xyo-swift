//
//  XyoBleServer.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_core_swift
import sdk_xyobleinterface_swift
import XyBleSdk

class XyoBleServer: XyoServer {
  weak var delegate: BoundWitnessDelegate?
  
  var relayNode: XyoRelayNode
  
  var procedureCatalog: XyoProcedureCatalog
  
  var listen: Bool = false {
    didSet(value) {
      if (value) {
        startListening()
      } else {
        stopListening()
      }
    }
  }
  
  var autoBridge: Bool = false
  var acceptBridging: Bool = false
  var advertiser: XyoBluetoothServer?

  required init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    self.procedureCatalog = procedureCatalog
    self.relayNode = relayNode
    self.advertiser = XyoBluetoothServer()
  }
  
  func startListening() {
    advertiser?.start(listener: self)
  }
  
  func stopListening() {
    advertiser?.stop()
  }
  
  convenience init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog, autoBridge: Bool, acceptBridging: Bool) {
    self.init(relayNode: relayNode, procedureCatalog: procedureCatalog)
    self.autoBridge = autoBridge
    self.acceptBridging = acceptBridging
  }
}

extension XyoBleServer : XyoPipeCharacteristicListener {
  
    // If acting as server
  func onPipe(pipe: XyoNetworkPipe) {
    delegate?.boundWitness(started: self)
    
    let handler = XyoNetworkHandler(pipe: pipe)
    
    self.relayNode.boundWitness(handler: handler, procedureCatalogue: self.procedureCatalog, completion: { [weak self] (boundWitness, error)  in
        guard error == nil else {
          self?.delegate?.boundWitness(failed: self, withError: error!)
            return
        }
        
        guard let bw = boundWitness, let strong = self else {
          self?.delegate?.boundWitness(failed: self, withError: XyoError.RESPONSE_IS_NULL)
            return
        }
      
        self?.delegate?.boundWitness(completed: strong, withBoundWitness: bw)
      
        pipe.close()

      })
  }
  
}
