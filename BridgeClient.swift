//
//  BridgeClient.swift
//  sdk-xyo-swift
//
//  Created by Kevin Weiler on 10/9/19.
//

import Foundation
class BridgeClient: SentinelClient, BridgeProtocol {
    var archivistUrl: NSURL
    
    var bridgeStatus: BridgeStatus
    
    var pendingBoundWitnesses: [BoundWitnessParseable]
    
    var delegate: BridgeDelegate
    
    static func buildBridge(withDelegate: BridgeDelegate) -> BridgeClient {
        <#code#>
    }
    
    func configure(archivist: NSURL, heuristicFetchers: [String : SentinelHeuristicFetcher]?, autoBridge: Bool) {
        <#code#>
    }
    
    func bridgePendingToArchivist() {
        <#code#>
    }
    
    ///...TODO

}
