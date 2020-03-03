//
//  XyoUnixTime.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/22/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/* 
  A simple unix time heuristic 
*/

public class XyoUnixTime : XyoObjectStructure {
    
    public func getUnixTime() throws -> UInt64 {
        return try getValueCopy().getUInt64(offset: 0)
    }
    
    public static func createNow () -> XyoUnixTime {
        let timeNow = UInt64(NSDate().timeIntervalSince1970) * 1000
        return createThen(time: timeNow)
    }
    
    public static func createThen (time : UInt64) -> XyoUnixTime {
        return XyoUnixTime(value: XyoObjectStructure.newInstance(schema: XyoSchemas.UNIX_TIME, bytes: XyoBuffer().put(bits: time)).getBuffer())
    }
}
