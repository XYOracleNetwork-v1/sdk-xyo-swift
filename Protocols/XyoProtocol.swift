//
//  XyProtocol.swift
//  SampleiOS
//
//  Created by Kevin Weiler on 10/7/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_core_swift
import CoreLocation
import sdk_objectmodel_swift
import XyBleSdk
import sdk_xyobleinterface_swift

enum AddressFormat {
    case hex
    case ethereumHex
}

struct ParseOptions {
    var addressFormat: AddressFormat = .hex
}

protocol BoundWitnessParseable {
    var boundWitness: XyoBoundWitness {get set}
    var options: ParseOptions {get set}
    
    init(_boundWitness: XyoBoundWitness, _options: ParseOptions?)
    
    // Throws if you can't get heuristic from BW for generic type
    // ExpectedHeuristic will be CLLocation, Data, String, or Int based on BoundWitness fetters
    func heuristic<ExpectedHeuristic>(forKey: String) -> ExpectedHeuristic
    
    // Addresses default to hex format
    func address(index: Int) -> String
    func allAddresses() -> [String]
    
    // In hex
    func signature(index: Int) -> String
    func allSignatures(format: String) -> [String]
    
    func asJson() -> [String: Any]
    func bytes() -> Data
    func hash() -> String
}

enum BoundWitnessHeuristicType {
    case location // CLLocation
    case data // Data
    case string // String
    case int // Int
}

protocol SentinelHeuristicFetcher {
    func getHeuristicType() -> BoundWitnessHeuristicType
    func getHeuristicKey() -> String
  
    // ExpectedHeuristic will be CLLocation, Data, String, or Int based on getHeuristicType()
    // Will throw if not as specified
    func getHeuristic<ExpectedHeuristicType>() -> ExpectedHeuristicType
}

protocol SentinelDelegate {
    func sentinelScan(detected devices: [XYBluetoothDevice], family: XYDeviceFamily)
    func sentinelScan(detected device: XYBluetoothDevice, rssi: Int, family: XYDeviceFamily)

    func boundWitness(didSucceed withBoundWitness: BoundWitnessParseable, withDevice: XYBluetoothDevice)
    func boundWitness(didFail withError: Error)
}

extension SentinelDelegate {
    func sentinelScan(detected device: XYBluetoothDevice, rssi: Int, family: XYDeviceFamily) {
        //this is a empty implementation to allow this method to be optional
    }
    func boundWitnessSuccess(boundWitness: BoundWitnessParseable, withDevice: XYBluetoothDevice) {
        //this is a empty implementation to allow this method to be optional
    }
    func boundWitnessFail(withError: Error) {
        //this is a empty implementation to allow this method to be optional
    }
}

typealias BoundWitnessCallback = (_ boundWitness: BoundWitnessParseable?, _ device: XyoBluetoothDevice?, _ error: Error?) -> ()

protocol SentinelProtocol {
    var delegate: SentinelDelegate {get}
    
    static func buildSentinel(withDelegate: SentinelDelegate) -> SentinelClient

    /// Configures origin chain and sets up heuristic getters
    func configure(heuristicFetchers: [String : SentinelHeuristicFetcher]?)
    
    func startScanningForDevices()
    func stopScanningForDevices()
        
    func doBoundWitness(withDevice: XyoBluetoothDevice) throws
    func doBoundWitnessWithSelf() throws
    func doBoundWitness(withDevice: XyoBluetoothDevice, withCompletion: BoundWitnessCallback) throws
    func doBoundWitnessWithSelf(withCompletion: BoundWitnessCallback) throws
  
    func originChainLength() -> Int
    func boundWitnessAtIndex(index: Int) -> BoundWitnessParseable
    
    // Hex formatted long form
    func originChainAddress() -> String
}

protocol BridgeDelegate {
    func bridgeConnection(didFail withError: Error)
    func bridgeConnection(didChangeState state: BridgeStatus)
    
    func bridging(didSucceed withBoundWitnesses: [BoundWitnessParseable])
    func bridging(didFail withError: Error)
}

protocol BridgeProtocol: SentinelProtocol {
    var archivistUrl: NSURL {get}
    var bridgeStatus: BridgeStatus {get}
    var pendingBoundWitnesses: [BoundWitnessParseable] {get}
    var delegate: BridgeDelegate {get}
    
    static func buildBridge(withDelegate: BridgeDelegate) -> BridgeClient

    func configure(archivist: NSURL, heuristicFetchers: [String : SentinelHeuristicFetcher]?, autoBridge: Bool)
    
    func bridgePendingToArchivist()
}

enum BridgeStatus: Int {
  case none
  case connecting
  case connected
  case disconnected
}
