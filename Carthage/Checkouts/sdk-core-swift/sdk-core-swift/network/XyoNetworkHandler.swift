//
//  XyoNetworkHandler.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/29/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public class XyoNetworkHandler {
    let pipe : XyoNetworkPipe
    
    public init(pipe: XyoNetworkPipe) {
        self.pipe = pipe
    }
    
    func sendCataloguePacket (catalogue : [UInt8], completion: @escaping (_: [UInt8]?)->()) {
        let buffer = getSizeEncodedCatalogue(catalogue: catalogue)
        
        pipe.send(data: buffer, waitForResponse: true, completion: completion)
    }
    
    func sendChoicePacket (catalogue : [UInt8], response : [UInt8], completion: @escaping (_: [UInt8]?)->()) {
        let buffer = XyoBuffer()
            .put(bytes: getSizeEncodedCatalogue(catalogue: catalogue))
            .put(bytes: response)
            .toByteArray()
        
        return pipe.send(data: buffer, waitForResponse: true, completion: completion)
    }
    
    private func getSizeEncodedCatalogue (catalogue : [UInt8]) -> [UInt8] {
        return XyoBuffer()
            .put(bits: UInt8(catalogue.count))
            .put(bytes: catalogue)
            .toByteArray()
    }

}
