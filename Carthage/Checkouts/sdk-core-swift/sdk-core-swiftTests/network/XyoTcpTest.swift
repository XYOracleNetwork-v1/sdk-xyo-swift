
//
//  TcpTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/29/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoTcpSocketTest : XCTestCase {
    
    func testClient () throws {
        /*if (false) {
            // true test must be run manualy
            let storage = XyoInMemoryStorage()
            let blocks = XyoStorageProviderOriginBlockRepository(storageProvider: storage,
                                                                hasher: XyoSha256())
            let state = XyoStorageOriginStateRepository(storage: storage)
            let conf = XyoRepositoryConfiguration(originState: state, originBlock: blocks)
            let node = XyoRelayNode(hasher: XyoSha256(),
                                    repositoryConfiguration: conf,
                                    queueRepository: XyoStorageBridgeQueueRepository(storage: storage))
            
            node.originState.addSigner(signer: XyoSecp256k1Signer())
            node.blocksToBridge.removeWeight = 50
            node.blocksToBridge.sendLimit = 100

            while (true) {
                // 3.80.173.107
                let peer = XyoTcpPeer(ip: "3.80.173.107", port: 11000)
                let socket = XyoTcpSocket.create(peer: peer)
                let pipe = XyoTcpSocketPipe(socket: socket, initiationData: nil)
                let handler = XyoNetworkHandler(pipe: pipe)

                let data = UInt32(XyoProcedureCatalogFlags.TAKE_ORIGIN_CHAIN | XyoProcedureCatalogFlags.GIVE_ORIGIN_CHAIN)
                node.boundWitness(handler: handler, procedureCatalogue: XyoFlagProcedureCatalog(forOther: data, withOther: data)) { (result, error) in
                        print(error)
                }
            }
        }*/
    }
}


