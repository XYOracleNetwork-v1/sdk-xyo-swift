//
//  XyoStorageTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

struct XyoStorageTests {
    
    static func testWrite (storageProvider : XyoStorageProvider) throws {
        let key : [UInt8] = [0x13, 0x37]
        let value : [UInt8] = [0x00, 0x01, 0x02, 0x03]
        
        XCTAssertFalse(try storageProvider.containsKey(key: key))
        try storageProvider.write(key: key, value: value)
        XCTAssertTrue(try storageProvider.containsKey(key: key))
    }
    
    static func testRead (storageProvider : XyoStorageProvider) throws {
        let key : [UInt8] = [0x13, 0x37]
        let value : [UInt8] = [0x00, 0x01, 0x02, 0x03]
        
        XCTAssertFalse(try storageProvider.containsKey(key: key))
        try storageProvider.write(key: key, value: value)
        XCTAssertTrue(try storageProvider.containsKey(key: key))
        guard let readValue = try storageProvider.read(key: key) else {
            throw XyoError.EXTREME_TESTING_ERROR
        }
        XCTAssertEqual(readValue, value)
    }
    
    static func testDelete (storageProvider : XyoStorageProvider) throws {
        let key : [UInt8] = [0x13, 0x37]
        let value : [UInt8] = [0x00, 0x01, 0x02, 0x03]
        
        XCTAssertFalse(try storageProvider.containsKey(key: key))
        try storageProvider.write(key: key, value: value)
        XCTAssertTrue(try storageProvider.containsKey(key: key))
        guard let readValue = try storageProvider.read(key: key) else {
            throw XyoError.EXTREME_TESTING_ERROR
        }
        XCTAssertEqual(readValue, value)
        try storageProvider.delete(key: key)
        
        XCTAssertNil(try storageProvider.read(key: key))
    }
    
    static func testContains (storageProvider : XyoStorageProvider) throws {
        let key : [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13, 0x37]
        let value : [UInt8] = [0x00, 0x01, 0x02, 0x03]
        
        XCTAssertFalse(try storageProvider.containsKey(key: key))
        try storageProvider.write(key: key, value: value)
        XCTAssertTrue(try storageProvider.containsKey(key: key))
        XCTAssertTrue(try storageProvider.containsKey(key: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13, 0x37]))
    }
    
}
