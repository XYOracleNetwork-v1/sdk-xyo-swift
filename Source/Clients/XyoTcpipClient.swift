//
//  XyoTcpipClient.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_core_swift

class XyoTcpipClient: XyoClient {
  
  var knownBridges: [String]?
  var relayNode: XyoRelayNode
  var procedureCatalog: XyoProcedureCatalog
  weak var delegate: BoundWitnessDelegate?

  var acceptBridging: Bool = false
  var autoBridge: Bool = false
  var autoBoundWitness: Bool = false
  var scan: Bool = false
  
  required init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    self.procedureCatalog = procedureCatalog
    self.relayNode = relayNode
  }
  
  convenience init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog, autoBridge: Bool, acceptBridging: Bool, autoBoundWitness: Bool) {
    self.init(relayNode: relayNode, procedureCatalog: procedureCatalog)
    self.autoBridge = autoBridge
    self.acceptBridging = acceptBridging
    self.autoBoundWitness = autoBoundWitness
    if (autoBridge) {
        _ = bridge()
    }
  }
  
  func bridge() -> String? {
    var errorMessage : String? = nil
    print("bridge - started: \(String(describing: knownBridges?.count))")
    if let bridges = knownBridges, knownBridges!.count > 0  {
      bridges.forEach { (bridge) in
        delegate?.boundWitness(didStart: self)
        if let url = URL(string: bridge) {
          let tcpDevice = XyoTcpPeer(ip: url.host!, port: UInt32(url.port!))
          let socket = XyoTcpSocket.create(peer: tcpDevice)
          let pipe = XyoTcpSocketPipe(socket: socket, initiationData: nil)
          let handler = XyoNetworkHandler(pipe: pipe)

          print("Trying to bridge [info]: \(String(describing: url.host)):\(String(describing: url.port))")
          relayNode.boundWitness(handler: handler, procedureCatalogue: procedureCatalog) { [weak self] (boundWitness, err) in
            if (err != nil) {
              self?.delegate?.boundWitness(failed: err!)
              return
            }
            if let bw = boundWitness, let strong = self {
              strong.delegate?.boundWitness(completed: tcpDevice.ip, withBoundWitness: bw)
            }
            
            pipe.close()
            if (self?.autoBridge == true) {
               _ = self?.bridge()
            }
          }
        }
      }
    } else {
      print("No known bridges, skipping bridging!")
      errorMessage = "No Known Bridges"
    }
    return errorMessage
  }
  deinit {
    print("Deallocing Tcpip Network")
  }
}
