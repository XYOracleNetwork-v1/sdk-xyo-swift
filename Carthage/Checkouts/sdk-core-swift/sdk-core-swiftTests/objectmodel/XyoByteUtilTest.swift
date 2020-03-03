//
//  XyoByteUtilTest.swift
//  sdk-objectmodel-swiftTests
//
//  Created by Carter Harrison on 1/21/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoByteUtiltest: XCTestCase {

    func testConcatAll () {
        let expectedArray: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09]
        let arrayOne: [UInt8] = [0x00, 0x01, 0x02, 0x03]
        let arrayTwo: [UInt8] = [0x04, 0x05, 0x06]
        let arrayThree: [UInt8] = [0x07, 0x08, 0x09]

        let totalArray: [[UInt8]] = [arrayOne, arrayTwo, arrayThree]

        XCTAssertEqual(XyoByteUtil.concatAll(arrays: totalArray), expectedArray)
    }

    func testGetBestSizeOne () {
        XCTAssertEqual(XyoObjectSize.ONE, XyoByteUtil.getBestSize(size: 0))
        XCTAssertEqual(XyoObjectSize.ONE, XyoByteUtil.getBestSize(size: 155))
        XCTAssertEqual(XyoObjectSize.ONE, XyoByteUtil.getBestSize(size: 254))
    }

    func testGetBestSizeTwo () {
        XCTAssertEqual(XyoObjectSize.TWO, XyoByteUtil.getBestSize(size: 255))
        XCTAssertEqual(XyoObjectSize.TWO, XyoByteUtil.getBestSize(size: 14033))
        XCTAssertEqual(XyoObjectSize.TWO, XyoByteUtil.getBestSize(size: Int(UInt16.max - UInt16(2))))
    }

    func testGetBestSizeFour () {
        XCTAssertEqual(XyoObjectSize.FOUR, XyoByteUtil.getBestSize(size: Int(UInt16.max)))
        XCTAssertEqual(XyoObjectSize.FOUR, XyoByteUtil.getBestSize(size: Int(UInt16.max) * Int(UInt16(4))))
        XCTAssertEqual(XyoObjectSize.FOUR, XyoByteUtil.getBestSize(size: Int(UInt32.max - UInt32(4))))
    }

    func testGetBestSizeEight () {
        XCTAssertEqual(XyoObjectSize.EIGHT, XyoByteUtil.getBestSize(size: Int(UInt32.max)))
        XCTAssertEqual(XyoObjectSize.EIGHT, XyoByteUtil.getBestSize(size: Int(UInt32.max) * Int(UInt32(4))))
    }

}
