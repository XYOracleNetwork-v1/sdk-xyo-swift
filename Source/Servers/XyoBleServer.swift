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
    didSet(newValue) {
      if (newValue) {
        startListening()
      } else {
        stopListening()
      }
    }
  }
  
  var autoBridge: Bool = false
  var acceptBridging: Bool = false
  var advertiser: XyoBluetoothServer

  required init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    self.procedureCatalog = procedureCatalog
    self.relayNode = relayNode
    self.advertiser = XyoBluetoothServer()
  }
  
  func startListening() {
    advertiser.start(listener: self)
  }
  
  func stopListening() {
    advertiser.stop()
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
    print("On Pipe Called")
    delegate?.boundWitness(started: "From an XYO Device")
    
    let handler = XyoNetworkHandler(pipe: pipe)
    DispatchQueue.global().async {

    self.relayNode.boundWitness(handler: handler, procedureCatalogue: self.procedureCatalog, completion: { [weak self] (boundWitness, error)  in
      DispatchQueue.main.async {
        guard error == nil else {
            self?.delegate?.boundWitness(failed: "From an XYO Device", withError: error!)
              return
          }
          
          guard let bw = boundWitness else {
            self?.delegate?.boundWitness(failed: "From an XYO Device", withError: XyoError.RESPONSE_IS_NULL)
              return
          }
        
          self?.delegate?.boundWitness(completed: "From an XYO Device", withBoundWitness: bw)
        
          pipe.close()
      }
        

      })
    }
  }
  
}
