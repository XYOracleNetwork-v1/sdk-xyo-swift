//
//  XyoFlagPrecedureCatalogueTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoFlagPrecedureCatalogueTest: XCTestCase {
    
    func testGetEncodedCatalogue () {
        let catalogue = XyoFlagProcedureCatalog(forOther: 1,
                                                  withOther: 1)
        
        XCTAssertEqual([0x00, 0x00, 0x00, 0x01], catalogue.getEncodedCatalogue())
    }
    
    func testCanDoFalseCaseOne () {
        let catalogue = XyoFlagProcedureCatalog(forOther: 1,
                                                  withOther: 1)
        
        XCTAssertEqual(false, catalogue.canDo(bytes: [0x01, 0x00]))
    }
    
    func testCanDoFalseCaseTwo () {
        let catalogue = XyoFlagProcedureCatalog(forOther: 4,
                                                  withOther: 4)
        
        XCTAssertEqual(false, catalogue.canDo(bytes: [0xff, 0x00, 0x01, 0x00]))
    }
    
    func testCanDoFalseCaseThree () {
        let catalogue = XyoFlagProcedureCatalog(forOther: 8,
                                                  withOther: 8)
                
        XCTAssertEqual(false, catalogue.canDo(bytes: [0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x01, 0x00]))
    }
    
    func testCanDoTrueCaseOne () {
        let catalogue = XyoFlagProcedureCatalog(forOther: 8,
                                                  withOther: 8)
        
        XCTAssertEqual(true, catalogue.canDo(bytes: [0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x01, 0xff]))
    }
    
    func testCanDoTrueCaseTwo () {
        let catalogue = XyoFlagProcedureCatalog(forOther: 8,
                                                  withOther: 8)
        
        XCTAssertEqual(true, catalogue.canDo(bytes: [0x08]))
    }
    
    func testCanDoTrueCaseThree () {
        let catalogue = XyoFlagProcedureCatalog(forOther: 1,
                                                  withOther: 1)
        
        
        XCTAssertEqual(true, catalogue.canDo(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]))
    }
        
}

