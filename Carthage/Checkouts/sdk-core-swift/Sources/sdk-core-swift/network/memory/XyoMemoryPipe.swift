//
//  XyoMemoryPipe.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 3/3/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

class XyoMemoryPipe : XyoNetworkPipe {
    var other : XyoMemoryPipe? = nil
    private var initiationData : XyoAdvertisePacket? = nil

    var awaitSendCompletion : (([UInt8]?) -> ())? = nil
    
    init() {
        
        awaitSendCompletion = { result in
            if (result != nil) {
                self.initiationData = XyoAdvertisePacket(data: result.unsafelyUnwrapped)
            }
        }
    }

    func getInitiationData() -> XyoAdvertisePacket? {
        return initiationData
    }
    
    func send(data: [UInt8], waitForResponse: Bool, completion: @escaping ([UInt8]?) -> ()) {
        awaitSendCompletion = completion
        other?.awaitSendCompletion?(data)
        
        if (!waitForResponse) {
            completion(nil)
        }
        
    }

    func close() {

    }
    
    func getNetworkHeuristics() -> [XyoObjectStructure] {
        return []
    }
    
}
