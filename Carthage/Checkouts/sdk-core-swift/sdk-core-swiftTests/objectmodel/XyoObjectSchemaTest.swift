//
//  XyoObjectSchemaTest.swift
//  sdk-objectmodel-swiftTests
//
//  Created by Carter Harrison on 1/21/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoObjectSchemaTest: XCTestCase {

    func testOneByteSize () {
        let header = XyoObjectSchema(id: 0xff, encodingCatalogue: 0x20)

        XCTAssertEqual(XyoObjectSize.ONE, header.getSizeIdentifier())
    }

    func testTwoByteSize () {
        let header = XyoObjectSchema(id: 0xff, encodingCatalogue: 0x60)

        XCTAssertEqual(XyoObjectSize.TWO, header.getSizeIdentifier())
    }

    func testFourByteSize () {
        let header = XyoObjectSchema(id: 0xff, encodingCatalogue: 0xa0)

        XCTAssertEqual(XyoObjectSize.FOUR, header.getSizeIdentifier())
    }

    func testEightByteSize () {
        let header = XyoObjectSchema(id: 0xff, encodingCatalogue: 0xe0)

        XCTAssertEqual(XyoObjectSize.EIGHT, header.getSizeIdentifier())
    }

    func testIterableFlagSet () {
        let header = XyoObjectSchema(id: 0xff, encodingCatalogue: 0x20)

        XCTAssertEqual(true, header.getIsIterable())
    }

    func testIterableFlagNotSet () {
        let header = XyoObjectSchema(id: 0xff, encodingCatalogue: 0x00)

        XCTAssertEqual(false, header.getIsIterable())
    }

    func testIterableTypeFlagSet () {
        let header = XyoObjectSchema(id: 0xff, encodingCatalogue: 0x30)

        XCTAssertEqual(true, header.getIsTypedIterable())
    }

    func testIterableTypeFlagNotSet () {
        let header = XyoObjectSchema(id: 0xff, encodingCatalogue: 0x20)

        XCTAssertEqual(false, header.getIsTypedIterable())
    }

    func testId () {
        let header = XyoObjectSchema(id: 0xff, encodingCatalogue: 0x20)

        XCTAssertEqual(0xff, header.id)
    }

    func testCreateCaseOne() {
        let schema = XyoObjectSchema.create(id: 0xff,
                                            isIterable: true,
                                            isTypedIterable: false,
                                            sizeIdentifier: XyoObjectSize.TWO)

        XCTAssertEqual(0xff, schema.id)
        XCTAssertEqual(true, schema.getIsIterable())
        XCTAssertEqual(false, schema.getIsTypedIterable())
        XCTAssertEqual(XyoObjectSize.TWO, schema.getSizeIdentifier())
    }

    func testCreateCaseTwo() {
        let schema = XyoObjectSchema.create(id: 0xff,
                                            isIterable: false,
                                            isTypedIterable: false,
                                            sizeIdentifier: XyoObjectSize.ONE)

        XCTAssertEqual(0xff, schema.id)
        XCTAssertEqual(false, schema.getIsIterable())
        XCTAssertEqual(false, schema.getIsTypedIterable())
        XCTAssertEqual(XyoObjectSize.ONE, schema.getSizeIdentifier())
    }

    func testCreateCaseThree() {
        let schema = XyoObjectSchema.create(id: 0xff,
                                            isIterable: true,
                                            isTypedIterable: true,
                                            sizeIdentifier: XyoObjectSize.EIGHT)

        XCTAssertEqual(0xff, schema.id)
        XCTAssertEqual(true, schema.getIsIterable())
        XCTAssertEqual(true, schema.getIsTypedIterable())
        XCTAssertEqual(XyoObjectSize.EIGHT, schema.getSizeIdentifier())
    }

    func testCreateCaseFour() {
        let schema = XyoObjectSchema.create(id: 0xff,
                                            isIterable: false,
                                            isTypedIterable: true,
                                            sizeIdentifier: XyoObjectSize.FOUR)

        XCTAssertEqual(0xff, schema.id)
        XCTAssertEqual(false, schema.getIsIterable())
        XCTAssertEqual(true, schema.getIsTypedIterable())
        XCTAssertEqual(XyoObjectSize.FOUR, schema.getSizeIdentifier())
    }
}
