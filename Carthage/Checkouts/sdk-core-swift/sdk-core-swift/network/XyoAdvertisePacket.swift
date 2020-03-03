//
//  XyoAdvertisePacket.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/29/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public struct XyoAdvertisePacket {
    private let data : [UInt8]
    
    public init(data : [UInt8]) {
        self.data = data
    }
    
    func getChoice () throws -> [UInt8] {
        if (data.count == 0) {
            throw XyoObjectError.OUTOFINDEX
        }
        
        let sizeOfChoice = Int(XyoBuffer(data: data).getUInt8(offset: 0))
        
        if (sizeOfChoice + 1 > data.count || sizeOfChoice == 0) {
            throw XyoObjectError.OUTOFINDEX
        }
        
        return XyoBuffer(data: data).copyRangeOf(from: 1, toEnd: sizeOfChoice + 1).toByteArray()
    }
}
