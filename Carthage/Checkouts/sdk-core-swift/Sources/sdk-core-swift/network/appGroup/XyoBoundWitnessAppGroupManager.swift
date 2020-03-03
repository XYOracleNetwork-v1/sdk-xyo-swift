//
//  XyoBoundWitnessAppGroupManager.swift
//  Pods-Receiver
//
//  Created by Darren Sutherland on 6/6/19.
//

import UIKit

public protocol XyoBoundWitnessAppGroupManagerDelegate: class {
    func complete()
}

public class XyoBoundWitnessAppGroupManager {

    public typealias BoundWitnessHandler = (
        XyoNetworkHandler,
        XyoProcedureCatalog, @escaping (XyoBoundWitness?, XyoError?) -> Void) -> Void

    private var asServer: Bool = false

    private var relayNode: XyoRelayNode?

    private var manager: XyoAppGroupPipeServer?

    private var onPipeHandler: BoundWitnessHandler?

    private weak var delegate: XyoBoundWitnessAppGroupManagerDelegate?

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    private class AppPipeCatalogue: XyoFlagProcedureCatalog {
        private static let allSupportedFunctions = UInt32(XyoProcedureCatalogFlags.BOUND_WITNESS)

        public init () {
            super.init(forOther: AppPipeCatalogue.allSupportedFunctions,
                       withOther: AppPipeCatalogue.allSupportedFunctions)
        }

        override public func choose(catalogue: [UInt8]) -> [UInt8] {
            guard let interestedFlags = catalogue.last else {
                return []
            }

            if interestedFlags & UInt8(XyoProcedureCatalogFlags.BOUND_WITNESS)
                != 0 && canDo(bytes: [UInt8(XyoProcedureCatalogFlags.BOUND_WITNESS)]) {
                return [UInt8(XyoProcedureCatalogFlags.BOUND_WITNESS)]
            }

            return []
        }
    }

    public init(_ delegate: XyoBoundWitnessAppGroupManagerDelegate) {
        self.delegate = delegate
        self.createNewRelayNode()
    }

    deinit {
        self.manager = nil
        self.onPipeHandler = nil
        self.endBackgroundTask()
    }

    private func endBackgroundTask() {
        // Cleanup of the task, otherwise iOS will kill the process
        UIApplication.shared.endBackgroundTask(self.backgroundTask)
        self.backgroundTask = .invalid
    }

    // The client requests a connection via an app-app URL connection
    public func initiate(identifier: String) {
        // Allow this to be run in the background as you are switching to the server app
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }

        // Create the manager if not already existing
        if self.manager == nil {
            self.manager = XyoAppGroupPipeServer(listener: self)
        }

        // Start the transfer
        guard let pipe = self.manager?.prepareConnection(identifier: String(identifier)) else { return }
        pipe.setFirstWrite { [weak self] in
            self?.relayNode?.boundWitness(
                handler: XyoNetworkHandler(pipe: pipe),
                procedureCatalogue: AppPipeCatalogue()) { _, _ in
            }
        }
    }

    // Used to setup the server side to handle the transfer of data
    public func server(handler: @escaping BoundWitnessHandler) {
        self.onPipeHandler = handler
        self.asServer = true

        // Create the manager if not already existing
        if self.manager == nil {
            self.manager = XyoAppGroupPipeServer(listener: self)
        }
    }

    // Notifes the server to allow the transfer
    public func start(identifier: String) {
        self.manager?.transfer(to: identifier)
    }

    private func createNewRelayNode() {
        do {
            let storage = XyoInMemoryStorage()
            let blocks = XyoStorageProviderOriginBlockRepository(storageProvider: storage, hasher: XyoSha256())
            let state = XyoStorageOriginStateRepository(storage: storage)
            let conf = XyoRepositoryConfiguration(originState: state, originBlock: blocks)

            let node = XyoRelayNode(hasher: XyoSha256(),
                                    repositoryConfiguration: conf,
                                    queueRepository: XyoStorageBridgeQueueRepository(storage: storage))

            let signer = XyoSecp256k1Signer()
            node.originState.addSigner(signer: signer)

            try node.selfSignOriginChain()

            self.relayNode = node
        } catch {
            fatalError("Node should be able to sign its chain")
        }
    }

}

extension XyoBoundWitnessAppGroupManager: XyoAppGroupPipeListener {

    public func complete() {
        self.delegate?.complete()
    }

    public func onPipe(pipe: XyoNetworkPipe) {
        guard self.asServer else { return }
        self.onPipeHandler?(XyoNetworkHandler(pipe: pipe), AppPipeCatalogue(), { _, _ in })
    }
}
