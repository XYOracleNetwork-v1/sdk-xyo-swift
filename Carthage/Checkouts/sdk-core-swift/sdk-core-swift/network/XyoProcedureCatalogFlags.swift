//
//  XyoProcedureCatalog.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public struct XyoProcedureCatalogFlags {
    public static let BOUND_WITNESS : UInt = 1
    public static let TAKE_ORIGIN_CHAIN : UInt = 2
    public static let GIVE_ORIGIN_CHAIN : UInt = 4
    
    public static func flip (flags: [UInt8]) -> [UInt8] {
        guard let interestedInByte = flags.last else {
            return []
        }
        
        if interestedInByte & UInt8(XyoProcedureCatalogFlags.TAKE_ORIGIN_CHAIN) != 0 {
            return [UInt8(XyoProcedureCatalogFlags.GIVE_ORIGIN_CHAIN)]
        }
        
        if interestedInByte & UInt8(XyoProcedureCatalogFlags.GIVE_ORIGIN_CHAIN) != 0 {
            return [UInt8(XyoProcedureCatalogFlags.TAKE_ORIGIN_CHAIN)]
        }
        
         return [UInt8(XyoProcedureCatalogFlags.BOUND_WITNESS)]
    }
}
