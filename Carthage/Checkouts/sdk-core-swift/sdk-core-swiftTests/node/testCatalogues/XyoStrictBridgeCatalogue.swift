//
//  XyoStrictBridgeCatalogue.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 4/8/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_core_swift

public class XyoBridgeProcedureStrictCatalogue : XyoFlagProcedureCatalog {
    private static let allSupportedFunctions = UInt32(
        XyoProcedureCatalogFlags.GIVE_ORIGIN_CHAIN |
            XyoProcedureCatalogFlags.TAKE_ORIGIN_CHAIN)
    
    public init () {
        super.init(forOther: XyoBridgeProcedureStrictCatalogue.allSupportedFunctions,
                   withOther: XyoBridgeProcedureStrictCatalogue.allSupportedFunctions)
    }
    
    override public func choose(catalogue: [UInt8]) -> [UInt8] {
        guard let intrestedFlags = catalogue.last else {
            return []
        }
        
        if (intrestedFlags & UInt8(XyoProcedureCatalogFlags.TAKE_ORIGIN_CHAIN) != 0 && canDo(bytes: [UInt8(XyoProcedureCatalogFlags.TAKE_ORIGIN_CHAIN)])) {
            return [UInt8(XyoProcedureCatalogFlags.GIVE_ORIGIN_CHAIN)]
        }
        
        if (intrestedFlags & UInt8(XyoProcedureCatalogFlags.GIVE_ORIGIN_CHAIN) != 0 && canDo(bytes: [UInt8(XyoProcedureCatalogFlags.GIVE_ORIGIN_CHAIN)])) {
            return [UInt8(XyoProcedureCatalogFlags.TAKE_ORIGIN_CHAIN)]
        }
        
        return []
    }
}
