//
//  XyoJustBoundWitnessCatalogues.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 4/8/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_core_swift

class TestInteractionCatalogueCaseOne : XyoFlagProcedureCatalog {
    private static let allSupportedFunctions = UInt32(XyoProcedureCatalogFlags.BOUND_WITNESS)
    
    public init () {
        super.init(forOther: TestInteractionCatalogueCaseOne.allSupportedFunctions,
                   withOther: TestInteractionCatalogueCaseOne.allSupportedFunctions)
    }
    
    override public func choose(catalogue: [UInt8]) -> [UInt8] {
        guard let intrestedFlags = catalogue.last else {
            fatalError()
        }
        
        if (intrestedFlags & UInt8(XyoProcedureCatalogFlags.BOUND_WITNESS) != 0 && canDo(bytes: [UInt8(XyoProcedureCatalogFlags.BOUND_WITNESS)])) {
            return [UInt8(XyoProcedureCatalogFlags.BOUND_WITNESS)]
        }
        
        fatalError()
    }
}
