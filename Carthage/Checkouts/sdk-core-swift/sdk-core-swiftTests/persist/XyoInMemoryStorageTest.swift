//
//  XyoInMemoryStorageTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoInMemoryStorageTests: XCTestCase {
    
    func testWrite () throws {
        try XyoStorageTests.testWrite(storageProvider: XyoInMemoryStorage())
    }
    
    func testRead () throws {
         try XyoStorageTests.testRead(storageProvider: XyoInMemoryStorage())
    }
    
    func testDelete () throws {
         try XyoStorageTests.testDelete(storageProvider: XyoInMemoryStorage())
    }
    
    func testContains () throws {
         try XyoStorageTests.testContains(storageProvider: XyoInMemoryStorage())
    }
    
}
