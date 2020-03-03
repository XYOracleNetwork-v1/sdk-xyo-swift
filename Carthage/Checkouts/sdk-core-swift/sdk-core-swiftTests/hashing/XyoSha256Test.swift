//
//  XyoSha256Test.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/22/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

import XCTest
@testable import sdk_core_swift

class XyoSha256Test: XCTestCase {
    
    func testSha256Value() throws {
        let calibration: [UInt8] = [0x01, 0x02, 0x03]
        let expectedHash = "039058C6F2C0CB492C533B0A4D14EF77CC0F78ABCCCED5287D84A1A2011CFB81".hexStringToBytes()
        let actualHash = XyoSha256().hash(data: calibration)
        
        XCTAssertEqual(expectedHash, try actualHash.getValueCopy().toByteArray())
    }
    
    func testSha256Id () throws {
        let calibration : [UInt8] = [0x01, 0x02, 0x03]
        let hash = XyoSha256().hash(data: calibration)
        
        XCTAssertEqual(XyoSchemas.SHA_256.id, try hash.getSchema().id)
    }
    
}
