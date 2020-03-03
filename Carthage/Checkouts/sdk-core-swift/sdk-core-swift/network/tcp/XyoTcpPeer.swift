//
//  XyoTcpPeer.swift
//  mod-ble-swift
//
//  Created by Carter Harrison on 2/12/19.
//
import Foundation

public struct XyoTcpPeer {
    public let ip : String
    public let port : UInt32
    
    public init (ip: String, port : UInt32) {
        self.ip = ip
        self.port = port
    }
}
