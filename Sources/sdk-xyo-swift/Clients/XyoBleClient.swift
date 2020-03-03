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

struct XyoBleClientError: Error {
    enum ErrorKind {
        case cannotConnect
    }
    let kind: ErrorKind
}


class XyoBleClient: XyoClient, XyoHeuristicGetter {  
 
  static let DefaultPollingTime = 6 // seconds

  var knownBridges: [String] = []
  var relayNode: XyoRelayNode
  var procedureCatalog: XyoProcedureCatalog
  var acceptBridging: Bool = false
  var autoBoundWitness: Bool = false
  var autoBridge: Bool = false
  var stringHeuristic: String?
  var enabledHeuristics: [XyoHeuristicEnum : XyoHeuristicGetter] = [:]

  weak var delegate: BoundWitnessDelegate?
  
  public var pollingInterval = DefaultPollingTime // seconds
  public var scan: Bool = false {
    didSet {
      if (scan) {
        startScanningForDevices()
      } else {
        stopScanningForDevices()
      }
    }
  }
  
  private weak var scanner = XYSmartScan.instance
  private var currentRssi : Int? = nil

  private var lastBoundWitnessTime = Date().addingTimeInterval(TimeInterval(-1 * DefaultPollingTime))
  
//  private var semaphore = DispatchSemaphore(value: 1)
  private var semaphore = true
  
  required init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    self.relayNode = relayNode
    self.procedureCatalog = procedureCatalog
    self.enableHeursitics(heuristics: [.time, .string], enabled: true)

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
    relayNode.addHeuristic(key: "rssi_client", getter: self)
  }
  
  func stopScanningForDevices() {
    scanner?.removeDelegate(for: "xyo_client")
    scanner?.stop()
    relayNode.removeHeuristic(key: "rssi_client")
  }

  deinit {
    print("XyoBleClient deinit")
  }
  
  typealias BoundWitnessCallback = ((_ boundWitness: XyoBoundWitness?, _ device: XyoBluetoothDevice?, _ error: Error?) -> Void)?
  
  func doBoundWitness(withDevice: XyoBluetoothDevice, withCompletion: BoundWitnessCallback) throws {
    
      self.delegate?.boundWitness(started: withDevice.id)

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
  }
  
  /// XyoHeuristicGetter
  func getHeuristic() -> XyoObjectStructure? {
    guard let rssi = currentRssi else { return nil }

    let unsignedRssi = UInt8(bitPattern: Int8(rssi))
    let rssiTag = XyoObjectStructure.newInstance(schema: XyoSchemas.RSSI, bytes: XyoBuffer().put(bits: (unsignedRssi)))
    return rssiTag
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
        if (Int(Date().timeIntervalSince(self.lastBoundWitnessTime)) > self.pollingInterval) {
          self.semaphore = false
          self.currentRssi = xyoDevice.rssi

          print("Initiatiting auto-boundwithness from scan")

          do {
            self.lastBoundWitnessTime = Date()
            try self.doBoundWitness(withDevice: xyoDevice)
            {
              [weak self]
              _,_,error in
              if let err = error {
                print("Error completing bound witness \(err)")
              }

              self?.semaphore = true
            }

          } catch {
            self.semaphore = true
            print("Error Recieved in bound witness \(error)")
          }

        }

      }

    }
  }
  
  func smartScan(exiting device: XYBluetoothDevice) {}
  func smartScan(exited device: XYBluetoothDevice) {}
}
