//
//  XyoTcpPeerRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/25/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/// This repository is meant to persist the state of tcp peers, although this is not called
/// in the XYO core, it may be used by other nodes and applications to persist the nodes that
/// they know about.
public protocol XyoTcpPeerRepository {
    
    /// This function should pick a random peer in all of the peers. This does not need to be
    /// truly random.
    /// - Returns: A random peer out of all the peers, and if none exist, will return nil.
    func getRandomPeer () -> XyoTcpPeer?
    
    /// This function should get all of the peers held in the repo.
    /// - Returns: Returns all of the peers inside of the repo, in no particular order.
    func getPeers () -> [XyoTcpPeer]
    
    /// Adds a peer to the repository. This function should persist the peer in no particular order.
    /// - Parameter peer: The peer to add to the repo.
    func addPeer (peer : XyoTcpPeer)
    
    /// This function should remove a peer from the repository and persist the state of the repo.
    /// - Parameter peer: The peer to remove from the repo, if no peer is found, skip the operation.
    func removePeer (peer : XyoTcpPeer)
}
