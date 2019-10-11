//
//  SentinelClient.swift
//  sdk-xyo-swift
//
//  Created by Kevin Weiler on 10/9/19.
//

import Foundation
import XyBleSdk
import Promises

import sdk_objectmodel_swift
import sdk_core_swift
import sdk_xyobleinterface_swift

class SentinelClient: SentinelProtocol  {
    
    private var boundWitness : XyoBoundWitness? = nil
    
    /// If the table view can show more devices, this is set to false when a user chooses to connect to a device.
    private var canUpdate = true
    
    /// The hasher to create bound witnesses with, (previous hashes)
    private let hasher = XyoSha256()
    
    /// The place to store all of the origin blocks after they are created, this will be cleared after the view is recreated
    private let storageProvider = XyoInMemoryStorage()
    
    /// The interface for talking to the storageProvider to store orgin blocks.
    private var blockRepo : XyoStorageProviderOriginBlockRepository
    
    /// The node that handles all of the bound witnessing.
    private var originChain : XyoRelayNode
    
    /// All of the current nearby devices to do bound witnesses with, this is the data in the listview.
    private var devices : [XYBluetoothDevice] = []
    
    /// The scanner to scan for XYO devices
    private let scanner = XYSmartScan.instance
    
    /// The server to let other devices to connect to do bound witnesses.
    private var server : XyoBluetoothServer!
    var delegate: SentinelDelegate
    
    private let device: XyoBluetoothDevice

    
    func configure(heuristicFetchers: [String : SentinelHeuristicFetcher]?) {
        self.blockRepo = XyoStorageProviderOriginBlockRepository(storageProvider: storageProvider, hasher: hasher)
        let originStateRepo = XyoStorageOriginStateRepository(storage: storageProvider)
        let bridgeRepo = XyoStorageBridgeQueueRepository(storage: storageProvider)
        let repositoryConfiguration = XyoRepositoryConfiguration(originState: originStateRepo, originBlock: self.blockRepo)
        
        self.originChain = XyoRelayNode(hasher: hasher, repositoryConfiguration: repositoryConfiguration, queueRepository: bridgeRepo)
        originChain.originState.addSigner(signer: XyoSecp256k1Signer())
        
                
        XyoBluetoothDevice.family.enable(enable: true)
        XyoBluetoothDeviceCreator.enable(enable: true)
        XyoSentinelXDeviceCreator().enable(enable: true)
        XyoBridgeXDeviceCreator().enable(enable: true)
        scanner.setDelegate(self, key: "main")
        server.start(listener: (self as XyoPipeCharacteristicLisitner))
        
        heuristicFetchers?.forEach { (key, fetcher) in
            print(key)
            self.originChain.addHeuristic(key: key, getter: HeuristicWrapper(_getter: fetcher))
        }
    }
    
    func startScanningForDevices() {
        scanner.start(mode: XYSmartScanMode.foreground)
    }
    
    func stopScanningForDevices() {
        scanner.stop()
    }


    
    func doBoundWitnessWithSelf() throws {
        try originChain.selfSignOriginChain()
    }
    
    private class BoundWitnessCatalog: XyoFlagProcedureCatalog {
        private static let allSupportedFunctions = UInt32(XyoProcedureCatalogFlags.BOUND_WITNESS)

        public init () {
            super.init(forOther: BoundWitnessCatalog.allSupportedFunctions,
                       withOther: BoundWitnessCatalog.allSupportedFunctions)
        }

        override public func choose(catalogue: [UInt8]) -> [UInt8] {
            guard let intrestedFlags = catalogue.last else {
                return []
            }

            if (intrestedFlags & UInt8(XyoProcedureCatalogFlags.BOUND_WITNESS) != 0 && canDo(bytes: [UInt8(XyoProcedureCatalogFlags.BOUND_WITNESS)])) {
                return [UInt8(XyoProcedureCatalogFlags.BOUND_WITNESS)]
            }

            return []
        }
    }
    
    func doBoundWitness(withDevice: XyoBluetoothDevice) throws {
        let awaiter = Promise<Any?>.pending()

        try self.doBoundWitnessWithSelf { [weak self] (boundWitness, withDevice, err) in

            guard err == nil else {
                return awaiter.reject(err!)
            }
            guard let bw = boundWitness, let strong = self else {
                self?.delegate.boundWitness(didFail: NSError(domain: "SentinelClient", code: 1001, userInfo: ["message": "No bound witness returned as server"]))
                return
            }
            strong.delegate.boundWitnessSuccess(boundWitness: bw, withDevice: withDevice!)

            return awaiter.fulfill(nil)

        }
        _ = try await(awaiter)
    }
    
    func doBoundWitness(withDevice: XyoBluetoothDevice, withCompletion: (BoundWitnessParseable?, XyoBluetoothDevice?, Error?) -> ()) throws {

        withDevice.connection {
        
            withDevice.connect()

            guard let pipe = withDevice.tryCreatePipe() else {
                withCompletion(nil, withDevice, NSError(domain: "SentinelClient", code: 1001, userInfo: ["message": "Can't create pipe"]))

                return
            }
            
            let handler = XyoNetworkHandler(pipe: pipe)

             
             DispatchQueue.global().async {
                 self.originChain.boundWitness(handler: handler, procedureCatalogue: XyoFlagProcedureCatalog(forOther: UInt32(XyoProcedureCatalogFlags.BOUND_WITNESS), withOther: UInt32(XyoProcedureCatalogFlags.BOUND_WITNESS)), completion: { [weak self] (boundWitness, error)  in
                    
                    
                     guard error == nil else {
                        withCompletion(nil, withDevice, error)
                         return
                     }
                     
                     guard let bw = boundWitness else {
                         self?.delegate.boundWitness(didFail: NSError(domain: "SentinelClient", code: 1001, userInfo: ["message": "No bound witness returned as server"]))
                         return
                     }
                    
                    withCompletion(BoundWitness(_boundWitness: bw, _options: nil), withDevice, nil)
                     pipe.close()

                 })
             }
        }
    }
    
    
    func doBoundWitnessWithSelf(withCompletion: (BoundWitnessParseable?, XyoBluetoothDevice?, Error?) -> ()) throws {
        try originChain.selfSignOriginChain()
    }
    
    func originChainLength() -> Int {
        return self.originChain.blocksToBridge.repo.getQueue().count
    }
    
    func boundWitnessAtIndex(index: Int) -> BoundWitnessParseable {
        <#code#>
    }
    
    func originChainAddress() -> String {
        <#code#>
    }
    
    private init(_device: XyoBluetoothDevice) {
        device = _device
    }
     
    static func buildSentinel(withDelegate: SentinelDelegate) -> SentinelClient {
        
    }
    
    ///...TODO
}

extension SentinelClient : XyoPipeCharacteristicLisitner {

    // If acting as server
    func onPipe(pipe: XyoNetworkPipe) {
        let handler = XyoNetworkHandler(pipe: pipe)
        
        DispatchQueue.global().async {
            self.originChain.boundWitness(handler: handler, procedureCatalogue: XyoFlagProcedureCatalog(forOther: UInt32(XyoProcedureCatalogFlags.BOUND_WITNESS), withOther: UInt32(XyoProcedureCatalogFlags.BOUND_WITNESS)), completion: { [weak self] (boundWitness, error)  in
                guard error == nil else {
                    self?.delegate.boundWitness(didFail: error!)
                    return
                }
                
                guard let bw = boundWitness, let strong = self else {
                    self?.delegate.boundWitness(didFail: NSError(domain: "SentinelClient", code: 1001, userInfo: ["message": "No bound witness returned as server"]))
                    return
                }
                strong.delegate.boundWitnessSuccess(boundWitness: BoundWitness(_boundWitness: bw, _options: nil), withDevice:strong.device )
                pipe.close()

            })
        }
    }
    
}


extension SentinelClient : XYSmartScanDelegate {
    func smartScan(detected devices: [XYBluetoothDevice], family: XYDeviceFamily) {
        self.devices = devices
    }
    
    func smartScan(status: XYSmartScanStatus) {}
    func smartScan(location: XYLocationCoordinate2D) {}
    func smartScan(detected device: XYBluetoothDevice, rssi: Int, family: XYDeviceFamily) {}
    func smartScan(entered device: XYBluetoothDevice) {}
    func smartScan(exiting device: XYBluetoothDevice) {}
    func smartScan(exited device: XYBluetoothDevice) {}
}
