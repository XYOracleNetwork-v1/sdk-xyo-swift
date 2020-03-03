//
//  XyoNetworkPipe.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/24/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public protocol XyoNetworkPipe {
    func getInitiationData() -> XyoAdvertisePacket?
    func getNetworkHeuristics() -> [XyoObjectStructure]
    func send (data: [UInt8], waitForResponse: Bool, completion: @escaping (_: [UInt8]?)->())
    func close ()
}
