//
//  XyoStorageProviderOriginBlockRepositoryTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation


import Foundation
import XCTest
@testable import sdk_core_swift

class XyoStorageProviderOriginBlockRepositoryTest: XCTestCase {
    
    func testAdd () throws {
        let repo = XyoStorageProviderOriginBlockRepository(storageProvider: XyoInMemoryStorage(), hasher: XyoSha256())
        try XyoOriginBlockRepositoryTests.testAdd(blockRepo: repo)
    }
    
    func testGet () throws {
        let repo = XyoStorageProviderOriginBlockRepository(storageProvider: XyoInMemoryStorage(), hasher: XyoSha256())
        try XyoOriginBlockRepositoryTests.testGet(blockRepo: repo)
    }
    
    func testRemove () throws {
        let repo = XyoStorageProviderOriginBlockRepository(storageProvider: XyoInMemoryStorage(), hasher: XyoSha256())
        try XyoOriginBlockRepositoryTests.testRemove(blockRepo: repo)
    }
    
    func testContains () throws {
        let repo = XyoStorageProviderOriginBlockRepository(storageProvider: XyoInMemoryStorage(), hasher: XyoSha256())
        try XyoOriginBlockRepositoryTests.testContains(blockRepo: repo)
    }
    
}
