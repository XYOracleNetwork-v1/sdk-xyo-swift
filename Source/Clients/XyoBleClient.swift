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
  var scan: Bool = false
  
  var acceptBridging: Bool
  
  var autoBridge: Bool
  
  var delegate: BoundWitnessDelegate?
  
  var relayNode: XyoRelayNode
  
  var procedureCatalog: XyoProcedureCatalog
  
  required init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    self.autoBridge = false
    self.acceptBridging = false
    self.relayNode = relayNode
    self.procedureCatalog = procedureCatalog
  }
  
  func doBoundWitness(withDevice: XyoBluetoothDevice) throws {
    let awaiter = Promise<Any?>.pending()
    self.delegate?.boundWitness(didStart: withDevice)

    try doBoundWitness(withDevice: withDevice) { [weak self] (boundWitness, withDevice, err) in
      guard err == nil else {
          return awaiter.reject(err!)
      }
      guard let bw = boundWitness, let strong = self else {
        self?.delegate?.boundWitness(didFail: XyoError.RESPONSE_IS_NULL)
          return
      }
      strong.delegate?.boundWitness(didComplete: bw, withDevice: withDevice!)
      return awaiter.fulfill(nil)

    }
    _ = try await(awaiter)
  }
  
  typealias BoundWitnessCallback = ((_ boundWitness: XyoBoundWitness?, _ device: XyoBluetoothDevice?, _ error: Error?) -> Void)?
  
  func doBoundWitness(withDevice: XyoBluetoothDevice, withCompletion: BoundWitnessCallback) throws {

      withDevice.connection {
      
        withDevice.connect()

        guard let pipe = withDevice.tryCreatePipe() else {
          withCompletion?(nil, withDevice, XyoError.UNKNOWN_ERROR)
            return
        }

        let handler = XyoNetworkHandler(pipe: pipe)

         
        self.relayNode.boundWitness(handler: handler, procedureCatalogue: self.procedureCatalog) { [weak self] (boundWitness, error)  in
          
          
           guard error == nil else {
              withCompletion?(nil, withDevice, error)
               return
           }
           
           guard let bw = boundWitness else {
            self?.delegate?.boundWitness(didFail: XyoError.RESPONSE_IS_NULL)
               return
           }
          
           withCompletion?(bw, withDevice, nil)
           pipe.close()

         }
      }
  }
}
