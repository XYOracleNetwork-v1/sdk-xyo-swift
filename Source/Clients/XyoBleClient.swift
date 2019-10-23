//
//  XyoBleClient.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import Promises
import sdk_core_swift
import XyBleSdk
import sdk_xyobleinterface_swift

class XyoBleClient: XyoClient {
  
  var knownBridges: [String]?
  var relayNode: XyoRelayNode
  var procedureCatalog: XyoProcedureCatalog
  weak var delegate: BoundWitnessDelegate?

  var acceptBridging: Bool = false
  var autoBoundWitness: Bool = false
  var autoBridge: Bool = false
  var scan: Bool = false {
    didSet(newValue) {
      if (newValue) {
        startScanningForDevices()
      } else {
        stopScanningForDevices()
      }
    }
  }
  
  private let scanner = XYSmartScan.instance
  private var minBWTimeGap = 10 //ten seconds
  private var lastBoundWitnessTime = Date()

  required init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    self.relayNode = relayNode
    self.procedureCatalog = procedureCatalog
    XyoBluetoothDevice.family.enable(enable: true)
    XyoBluetoothDeviceCreator.enable(enable: true)
  }
  
    convenience init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog, autoBridge: Bool, acceptBridging: Bool, autoBoundWitness: Bool) {
    self.init(relayNode: relayNode, procedureCatalog: procedureCatalog)
    self.autoBridge = autoBridge
    self.acceptBridging = acceptBridging
    self.autoBoundWitness = autoBoundWitness
  }
  
  func startScanningForDevices() {
    scanner.setDelegate(self, key: "xyo_client")
    scanner.start(mode: XYSmartScanMode.foreground)
  }
  
  func stopScanningForDevices() {
    scanner.removeDelegate(for: "xyo_client")
    scanner.stop()
  }

  func doBoundWitness(withDevice: XyoBluetoothDevice) throws {
    let awaiter = Promise<Any?>.pending()

    try doBoundWitness(withDevice: withDevice) { (boundWitness, withDevice, err) in
      guard err == nil else {
          return awaiter.reject(err!)
      }
      guard let bw = boundWitness else {
          return
      }
      return awaiter.fulfill(bw)

    }
    _ = try await(awaiter)
  }
  
  typealias BoundWitnessCallback = ((_ boundWitness: XyoBoundWitness?, _ device: XyoBluetoothDevice?, _ error: Error?) -> Void)?
  
  func doBoundWitness(withDevice: XyoBluetoothDevice, withCompletion: BoundWitnessCallback) throws {
      self.delegate?.boundWitness(started: withDevice.id)
//    DispatchQueue.main.sync {
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
            self?.delegate?.boundWitness(failed: withDevice.id, withError: XyoError.RESPONSE_IS_NULL)
             return
           }
            
           self?.lastBoundWitnessTime = Date()
          self?.delegate?.boundWitness(completed: withDevice.id, withBoundWitness: bw)
           withCompletion?(bw, withDevice, nil)
          print("Closing pipe")

           pipe.close()

         }
      }.then {
        print("Disconnecting device")
        withDevice.disconnect()
      }.catch { (err) in
        print("CAUGHT ERROR \(err)")
        withCompletion?(nil, nil, err)
    }
//    }
  }
}

extension XyoBleClient : XYSmartScanDelegate {
    func smartScan(entered device: XYBluetoothDevice) {
      
    }
  
    func smartScan(detected devices: [XYBluetoothDevice], family: XYDeviceFamily) {
      DispatchQueue.main.async {
      print("devices detected", devices.count)
      }
    }
  
    func smartScan(status: XYSmartScanStatus) {}
    func smartScan(location: XYLocationCoordinate2D) {}
    func smartScan(detected device: XYBluetoothDevice, rssi: Int, family: XYDeviceFamily) {
      DispatchQueue.main.async{
//        guard let self = self else {
//          return
//        }
      print("device detected")
      if (self.autoBoundWitness) {
        if let xyoDevice = device as? XyoBluetoothDevice {
          if (Int(Date().timeIntervalSince(self.lastBoundWitnessTime)) > self.minBWTimeGap) {
            print("Initiatiting auto-boundwithness from scan")

            do {
              try self.doBoundWitness(withDevice: xyoDevice)
              
            } catch {
              print("Error Recieved in bound witness")
            }
          }
        }
      }
      }
  }
    func smartScan(exiting device: XYBluetoothDevice) {}
    func smartScan(exited device: XYBluetoothDevice) {}
}
