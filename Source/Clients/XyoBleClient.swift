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
struct XyoBleClientError: Error {
    enum ErrorKind {
        case cannotConnect
    }
    let kind: ErrorKind
}

class XyoBleClient: XyoClient {
  
  var knownBridges: [String]?
  var relayNode: XyoRelayNode
  var procedureCatalog: XyoProcedureCatalog
  weak var delegate: BoundWitnessDelegate?

  var acceptBridging: Bool = false
  var autoBoundWitness: Bool = false
  var autoBridge: Bool = false
  var scan: Bool = false {
    didSet {
      if (scan) {
        startScanningForDevices()
      } else {
        stopScanningForDevices()
      }
    }
  }
  
  private weak var scanner = XYSmartScan.instance
  private var minBWTimeGap = 6 //ten seconds
  private var lastBoundWitnessTime = Date()
  
//  private var semaphore = DispatchSemaphore(value: 1)
  private var semaphore = true

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
    scanner?.setDelegate(self, key: "xyo_client")
    scanner?.start(mode: XYSmartScanMode.foreground)
  }
  
  func stopScanningForDevices() {
    scanner?.removeDelegate(for: "xyo_client")
    scanner?.stop()
  }

  deinit {
    print("XyoBleClient deinit")
  }
  
  typealias BoundWitnessCallback = ((_ boundWitness: XyoBoundWitness?, _ device: XyoBluetoothDevice?, _ error: Error?) -> Void)?
  
  func doBoundWitness(withDevice: XyoBluetoothDevice, withCompletion: BoundWitnessCallback) throws {
      self.delegate?.boundWitness(started: withDevice.id)
//    DispatchQueue.main.sync {
      withDevice.connection {
        [weak self] in
        withDevice.connect()
        guard let pipe = withDevice.tryCreatePipe(), let strong = self else {
          DispatchQueue.main.async {

          withCompletion?(nil, withDevice, XyoError.UNKNOWN_ERROR)
          }
          return

        }

        let handler = XyoNetworkHandler(pipe: pipe)
        strong.relayNode.boundWitness(handler: handler, procedureCatalogue: strong.procedureCatalog) {  (boundWitness, error)  in

          print("Disconnecting device")
          withDevice.disconnect()
          DispatchQueue.main.async {
                       guard error == nil else {
                withCompletion?(nil, withDevice, error)
                 return
             }
             
             guard let bw = boundWitness else {
              strong.delegate?.boundWitness(failed: withDevice.id, withError: XyoError.RESPONSE_IS_NULL)
               return
             }
              
            strong.delegate?.boundWitness(completed: withDevice.id, withBoundWitness: bw)
             withCompletion?(bw, withDevice, nil)
          }

         }
      }.then {
        withDevice.disconnect()
      }.catch { (err) in
        withDevice.disconnect()
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
      if (self.autoBoundWitness && self.semaphore) {

      if let xyoDevice = device as? XyoBluetoothDevice {
        if (Int(Date().timeIntervalSince(self.lastBoundWitnessTime)) > self.minBWTimeGap) {
          self.semaphore = false
          print("Initiatiting auto-boundwithness from scan")

          do {
            self.lastBoundWitnessTime = Date()
            try self.doBoundWitness(withDevice: xyoDevice)
            {
              [weak self]
              _,_,_ in
              print("FINISHED")
              self?.semaphore = true
            }

          } catch {
            self.semaphore = true

            print("Error Recieved in bound witness")
          }

        }

      }

    }
  }
  
  func smartScan(exiting device: XYBluetoothDevice) {}
  func smartScan(exited device: XYBluetoothDevice) {}
}
