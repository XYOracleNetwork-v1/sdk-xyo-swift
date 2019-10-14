//
//  XyoBleClient.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_xyobleinterface_swift
import Promises
import sdk_core_swift
import XyBleSdk

class XyoBleClient: XyoClient {
  var scan: Bool
  
  var acceptBridging: Bool
  
  var autoBridge: Bool
  
  var delegate: BoundWitnessDelegate?
  
  var relayNode: XyoRelayNode
  
  var procedureCatalog: XyoProcedureCatalog
  
  required init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    self.autoBridge = false
    self.acceptBridging = false
  }
  
  func doBoundWitness(withDevice: XyoBluetoothDevice) throws {
    let awaiter = Promise<Any?>.pending()
    self.delegate?.boundWitness(didStart: withDevice)

    try doBoundWitness(withDevice: withDevice) { [weak self] (boundWitness, withDevice, err) in
      guard err == nil else {
          return awaiter.reject(err!)
      }
      guard let bw = boundWitness, let strong = self else {
          self?.delegate?.boundWitness(didFail: NSError(domain: "XyoBleClient", code: 1001, userInfo: ["message": "No bound witness returned as server"]))
          return
      }
      strong.delegate?.boundWitness(didComplete: bw, withDevice: withDevice!)
      return awaiter.fulfill(nil)

    }
    _ = try await(awaiter)
  }
  
  func doBoundWitness(withDevice: XyoBluetoothDevice, withCompletion: (BoundWitnessParseable?, XyoBluetoothDevice?, Error?) -> ()) throws {

      withDevice.connection {
      
        withDevice.connect()

        guard let pipe = withDevice.tryCreatePipe() else {
            withCompletion(nil, withDevice, NSError(domain: "XyoBleClient", code: 1001, userInfo: ["message": "Can't create pipe"]))

            return
        }
        
        let handler = XyoNetworkHandler(pipe: pipe)

         
         DispatchQueue.global().async {
           self.relayNode.boundWitness(handler: handler, procedureCatalogue: XyoFlagProcedureCatalog(forOther: UInt32(XyoProcedureCatalogFlags.BOUND_WITNESS), withOther: UInt32(XyoProcedureCatalogFlags.BOUND_WITNESS)), completion: { [weak self] (boundWitness, error)  in
              
              
             guard error == nil else {
                withCompletion(nil, withDevice, error)
                 return
             }
             
             guard let bw = boundWitness else {
                 self?.delegate?.boundWitness(didFail: NSError(domain: "XyoBleClient", code: 1001, userInfo: ["message": "No bound witness returned as server"]))
                 return
             }
            
             withCompletion(BoundWitness(_boundWitness: bw, _options: nil), withDevice, nil)
             pipe.close()

         })
       }
      }
  }
}
