//
//  XyoFlagProcedureCatalog.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/// This
open class XyoFlagProcedureCatalog: XyoProcedureCatalog {
    private let encodedCatalogue : [UInt8]
    private let encodedCatalogueWithOther : [UInt8]
    public let canDoForOther : UInt32
    public let canDoWithOther : UInt32
    
    public init(forOther : UInt32, withOther : UInt32) {
        self.canDoForOther = forOther
        self.canDoWithOther = withOther
        self.encodedCatalogue = XyoBuffer()
            .put(bits: canDoForOther)
            .toByteArray()
        
        self.encodedCatalogueWithOther = XyoBuffer()
            .put(bits: canDoWithOther)
            .toByteArray()
    }
    
    public func canDo (bytes : [UInt8]) -> Bool {
        for i in 0...(min(bytes.count, encodedCatalogue.count) - 1) {
            let otherCatalogueSection = bytes[bytes.count - i - 1]
            let thisCatalogueSection = encodedCatalogueWithOther[encodedCatalogue.count - i - 1]
            
            if (otherCatalogueSection & thisCatalogueSection != 0) {
                return true
            }
        }
        
        return false
    }
    
    public func getEncodedCatalogue() -> [UInt8] {
        return encodedCatalogue
    }
    
    open func choose(catalogue: [UInt8]) -> [UInt8] {
        return [UInt8(XyoProcedureCatalogFlags.BOUND_WITNESS)]
    }
}
