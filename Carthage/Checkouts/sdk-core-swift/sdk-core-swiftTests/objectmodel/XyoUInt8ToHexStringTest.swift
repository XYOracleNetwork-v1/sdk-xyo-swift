//
//  XyoUInt8ToHexStringTest.swift
//  sdk-objectmodel-swiftTests
//
//  Created by Carter Harrison on 1/21/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoUInt8ToHexStringTest: XCTestCase {

    func testCaseOne () {
        let bytes: [UInt8] = [0x13, 0x37]

        XCTAssertEqual(bytes.toHexString(), "0x1337")
    }

    func testCaseTwo () {
        let bytes: [UInt8] = [0xff, 0xff]

        XCTAssertEqual(bytes.toHexString(), "0xFFFF")
    }

    func testCaseThree () {
        let bytes: [UInt8] = [0x12, 0x34, 0x56, 0x78, 0xab, 0xcd, 0xef]

        XCTAssertEqual(bytes.toHexString(), "0x12345678ABCDEF")
    }

}
