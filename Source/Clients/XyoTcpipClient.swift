//
//  XyoTcpipClient.swift
//  sdk
//
//  Created by Arie Trouw on 10/11/19.
//  Copyright © 2019 Arie Trouw. All rights reserved.
//

import Foundation
import sdk_core_swift

struct TcpipClientError : Error {
  enum ErrorKind {
    case noBridges
  }
  let kind : ErrorKind
  
}


class XyoTcpipClient: XyoClient {
  var knownBridges: [String] = []
  var relayNode: XyoRelayNode
  var procedureCatalog: XyoProcedureCatalog
  weak var delegate: BoundWitnessDelegate?

  var acceptBridging: Bool = false
  var autoBridge: Bool = false {
    didSet {
      if (autoBridge) {
        relayNode.addListener(key: "auto-bridging", listener: self)
      } else {
        relayNode.removeListener(key: "auto-bridging")
      }
    }
  }
  var autoBoundWitness: Bool = false
  var scan: Bool = false
  var semaphore = true
  var ignoreLastBridgeBW : String? = nil
  required init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog) {
    self.procedureCatalog = procedureCatalog
    self.relayNode = relayNode
  }
  
  convenience init(relayNode: XyoRelayNode, procedureCatalog: XyoProcedureCatalog, autoBridge: Bool, acceptBridging: Bool, autoBoundWitness: Bool) {
    self.init(relayNode: relayNode, procedureCatalog: procedureCatalog)
    self.autoBridge = autoBridge
    self.acceptBridging = acceptBridging
    self.autoBoundWitness = autoBoundWitness
  }
  
  func startBridging() {
    guard autoBridge == true && semaphore == true else {return}
    print("Bound witness discovered, starting bridging")

    do {
      try bridge()
    } catch {
      print("Cant start bridging \(error)")
    }
  }
  
  func bridge() throws {
    guard semaphore == true, knownBridges.count > 0 else {
      if knownBridges.count == 0 {
        print("No known bridges")
      }
      return
    }
    semaphore = false
    
    knownBridges.forEach { (bridge) in
      delegate?.boundWitness(didStart: self)
        let url = URL(string: bridge)!
        let tcpDevice = XyoTcpPeer(ip: url.host!, port: UInt32(url.port!))
        let socket = XyoTcpSocket.create(peer: tcpDevice)
        let pipe = XyoTcpSocketPipe(socket: socket, initiationData: nil)
        let handler = XyoNetworkHandler(pipe: pipe)

        print("Trying to bridge: \(String(describing: url.host)):\(String(describing: url.port))")
        relayNode.boundWitness(handler: handler, procedureCatalogue: procedureCatalog) { [weak self] (boundWitness, err) in
          guard let strong = self else {return}
          if (err != nil) {
            DispatchQueue.main.async {
              strong.delegate?.boundWitness(failed: err!)
            }
            strong.semaphore = true
            return
          }
          strong.ignoreLastBridgeBW = try? boundWitness?.getHash(hasher: strong.relayNode.hasher).getBuffer().toByteArray().toHexString()

          pipe.close()

          if let bw = boundWitness, let strong = self {
            DispatchQueue.main.async {
              strong.delegate?.boundWitness(completed: tcpDevice.ip, withBoundWitness: bw)
            }
          }
          strong.semaphore = true
        }
      }
  }
  
  deinit {
    print("Deallocing Tcpip Network")
    relayNode.removeListener(key: "auto-bridging")
  }
}

extension XyoTcpipClient : XyoNodeListener {
  func onBoundWitnessStart() {
    
  }
  
  func onBoundWitnessEndFailure() {
    
  }
  
  func onBoundWitnessEndSuccess(boundWitness: XyoBoundWitness) {
    DispatchQueue.main.async { [weak self] in
      guard let strong = self else { return }
      
      let bwHash = try? boundWitness.getHash(hasher: strong.relayNode.hasher).getBuffer().toByteArray().toHexString()

      if (bwHash != strong.ignoreLastBridgeBW) {
        self?.startBridging()
      }
    }
  }
  
  func onBoundWitnessDiscovered(boundWitness: XyoBoundWitness) {

  }
}
