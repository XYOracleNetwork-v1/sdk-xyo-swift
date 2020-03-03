//
//  XyoStorageTcpPeerRepository.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/25/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public class XyoStorageTcpPeerRepository : XyoTcpPeerRepository {
    
    private static let PEER_ARRAY_INDEX_KEY = Array("PEER_ARRAY_INDEX_KEY".utf8)
    
    private var peerCache = [XyoTcpPeer]()
    private let storage : XyoStorageProvider
    
    public init (storage : XyoStorageProvider) {
        self.storage = storage
    }
    
    public func getRandomPeer() -> XyoTcpPeer? {
        let allPeers = getPeers()
        
        if (allPeers.count > 0) {
            return nil
        }
        
        return allPeers[Int(arc4random_uniform(UInt32(allPeers.count)))]
    }
    
    public func getPeers() -> [XyoTcpPeer] {
        return peerCache
    }
    
    public func addPeer(peer: XyoTcpPeer) {
        peerCache = getPeers()
        peerCache.append(peer)
        savePeerList(peers: peerCache)
    }
    
    public func removePeer(peer: XyoTcpPeer) {
        removePeerFromCache(peer: peer)
        savePeerList(peers: peerCache)
    }
    
    private func restorePeers () {
        var peers = [XyoTcpPeer]()
        let stringPeers = getPeerIndex()
        
        for i in 0...stringPeers.count {
            let peer = stringPeerToTcpPeer(string: stringPeers[i])
            
            if (peer != nil) {
                peers.append(peer!)
            }
        }
        
        peerCache = peers
    }
    
    private func savePeerList (peers : [XyoTcpPeer]) {
        var structures = [XyoObjectStructure]()
        
        for peer in peers {
            let content = XyoBuffer(data: Array(tcpPeerToStringPeer(peer: peer).utf8))
            let structure = XyoObjectStructure.newInstance(schema: XyoSchemas.BLOB, bytes: content)
            structures.append(structure)
        }
        
        let encodedIndex = XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.ARRAY_TYPED, values: structures).getBuffer().toByteArray()
        
        do {
            try storage.write(key: XyoStorageTcpPeerRepository.PEER_ARRAY_INDEX_KEY, value: encodedIndex)
        } catch  {
            // todo handle this error
        }
    }
    
    private func stringPeerToTcpPeer (string : String) -> XyoTcpPeer? {
        let sections = string.split(separator: ":")
        
        if (sections.count != 2) {
            return nil
        }
        
        let ip = String(sections[0])
        guard let port = UInt32(sections[1]) else {
            return nil
        }
        
        return XyoTcpPeer(ip: ip, port: port)
    }
    
    private func tcpPeerToStringPeer (peer : XyoTcpPeer) -> String {
        return "\(peer.ip):\(peer.port)"
    }
    
    private func getPeerIndex () -> [String] {
        do {
            var peers = [String]()
            
            guard let encodedPeersArray = try storage.read(key: XyoStorageTcpPeerRepository.PEER_ARRAY_INDEX_KEY) else {
                return []
            }
            
            let peersArrayIt = try XyoIterableStructure(value: XyoBuffer(data: encodedPeersArray)).getNewIterator()
            
            while try peersArrayIt.hasNext() {
                let peer = String(bytes: try peersArrayIt.next().getValueCopy().toByteArray(), encoding: String.Encoding.utf8)
                
                if (peer != nil) {
                    peers.append(peer!)
                }
            }
            
            return peers
        } catch {
            return []
        }
    }
    
    private func removePeerFromCache (peer: XyoTcpPeer) {
        guard let indexOfPeer = (peerCache.firstIndex { (cachedPeer) -> Bool in
            let ipSame = peer.ip == cachedPeer.ip
            
            if (ipSame) {
                return peer.port == cachedPeer.port
            }
            
            return false
        }) else { return }
        
        peerCache.remove(at: indexOfPeer)
    }
}
