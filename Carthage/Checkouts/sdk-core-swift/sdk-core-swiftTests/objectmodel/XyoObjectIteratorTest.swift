//
//  XyoObjectIteratorTest.swift
//  sdk-objectmodel-swiftTests
//
//  Created by Carter Harrison on 1/21/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoObjectIteratorTest: XCTestCase {
    let itemOneSchema = XyoObjectSchema.create(id: 0x55,
                                                isIterable: false,
                                                isTypedIterable: false,
                                                sizeIdentifier: XyoObjectSize.ONE)

    let itemTwoSchema = XyoObjectSchema.create(id: 0x55,
                                                isIterable: false,
                                                isTypedIterable: false,
                                                sizeIdentifier: XyoObjectSize.ONE)

    func testCreateUntypedIterableObject () throws {
        let iterableSchema = XyoObjectSchema.create(id: 0xff,
                                            isIterable: true,
                                            isTypedIterable: false,
                                            sizeIdentifier: XyoObjectSize.ONE)

        let values: [XyoObjectStructure] = [
            XyoObjectStructure.newInstance(schema: itemOneSchema, bytes: XyoBuffer(data: [0x13, 0x37])),
            XyoObjectStructure.newInstance(schema: itemTwoSchema, bytes: XyoBuffer(data: [0x13, 0x37]))
        ]

        let expectedIterable: [UInt8] = [0x20, 0xff,   // root header
                                          0x0b,         // size of entire array
                                          0x00, 0x55,   // header of element [0]
                                          0x03,         // size of element [0]
                                          0x13, 0x37,   // value of element [0]
                                          0x00, 0x55,   // header of element [1]
                                          0x03,         // size of element [1]
                                          0x13, 0x37]   // value of element [1]

        let createdSet = XyoIterableStructure.createUntypedIterableObject(schema: iterableSchema, values: values)

        XCTAssertEqual(createdSet.value.toByteArray(), expectedIterable)
    }

    func testCreateTypedIterableObject () throws {
        let iterableSchema = XyoObjectSchema.create(id: 0xff,
                                                    isIterable: true,
                                                    isTypedIterable: true,
                                                    sizeIdentifier: XyoObjectSize.ONE)

        let values: [XyoObjectStructure] = [
            XyoObjectStructure.newInstance(schema: itemOneSchema, bytes: XyoBuffer(data: [0x13, 0x37])),
            XyoObjectStructure.newInstance(schema: itemTwoSchema, bytes: XyoBuffer(data: [0x13, 0x37]))
        ]

        let expectedIterable: [UInt8] = [0x30, 0xff, // root header
                                         0x09,       // size of entire array
                                         0x00, 0x55, // header for all elements
                                         0x03,       // size of element [0]
                                         0x13, 0x37, // value of element [0]
                                         0x03,       // size of element [1]
                                         0x13, 0x37] // value of element [1]

        let createdSet = try XyoIterableStructure.createTypedIterableObject(schema: iterableSchema, values: values)

        XCTAssertEqual(createdSet.value.toByteArray(), expectedIterable)
    }

    func testObjectIteratorUntyped () throws {
        let iterableStructure = XyoIterableStructure(value:
            XyoBuffer(data: [0x20, 0x41, 0x09, 0x00, 0x44, 0x02, 0x14, 0x00, 0x42, 0x02, 0x37]))
        let iterable = try iterableStructure.getNewIterator()
        var index = 0

        while try iterable.hasNext() {
            if index == 0 {
                let bytes = try iterable.next().getBuffer().toByteArray()
                XCTAssertEqual(bytes, [0x00, 0x44, 0x02, 0x14])
            } else if index == 1 {
                let bytes = try iterable.next().getBuffer().toByteArray()
                XCTAssertEqual(bytes, [0x00, 0x42, 0x02, 0x37])
            } else {
                throw XyoObjectError.OUTOFINDEX
            }

            index += 1
        }
    }

    func testObjectIteratorTyped () throws {
        let iterableStructure = XyoIterableStructure(value:
            XyoBuffer(data: [0x30, 0x41, 0x07, 0x00, 0x44, 0x02, 0x13, 0x02, 0x37]))
        let iterable = try iterableStructure.getNewIterator()
        var index = 0

        while try iterable.hasNext() {
            if index == 0 {
                let bytes = try iterable.next().getBuffer().toByteArray()
                XCTAssertEqual(bytes, [0x00, 0x44, 0x02, 0x13])
            } else if index == 1 {
                let bytes = try iterable.next().getBuffer().toByteArray()
                XCTAssertEqual(bytes, [0x00, 0x44, 0x02, 0x37])
            } else {
                throw XyoObjectError.OUTOFINDEX
            }

            index += 1
        }
    }

    func testAddToUntyped () throws {
        let iterableSchema = XyoObjectSchema.create(id: 0xff,
                                                    isIterable: true,
                                                    isTypedIterable: false,
                                                    sizeIdentifier: XyoObjectSize.ONE)

        let values: [XyoObjectStructure] = [
            XyoObjectStructure.newInstance(schema: itemOneSchema, bytes: XyoBuffer(data: [0x13, 0x37])),
            XyoObjectStructure.newInstance(schema: itemTwoSchema, bytes: XyoBuffer(data: [0x13, 0x37]))
        ]

        let itemToAdd = XyoObjectStructure.newInstance(schema: itemOneSchema, bytes: XyoBuffer(data: [0x13, 0x37]))

        let expectedIterable: [UInt8] = [0x20, 0xff,   // root header
                                         0x10,         // size of entire array
                                         0x00, 0x55,   // header of element [0]
                                         0x03,         // size of element [0]
                                         0x13, 0x37,   // value of element [0]
                                         0x00, 0x55,   // header of element [1]
                                         0x03,         // size of element [1]
                                         0x13, 0x37,
                                         0x00, 0x55,   // header of element [2]
                                         0x03,         // size of element [2]
                                         0x13, 0x37]   // value of element [2]

        let createdSet = XyoIterableStructure.createUntypedIterableObject(schema: iterableSchema, values: values)
        try createdSet.addElement(element: itemToAdd)

        XCTAssertEqual(createdSet.value.toByteArray(), expectedIterable)
    }

    func testAddToTyped () throws {
        let iterableSchema = XyoObjectSchema.create(id: 0xff,
                                                    isIterable: true,
                                                    isTypedIterable: true,
                                                    sizeIdentifier: XyoObjectSize.ONE)

        let values: [XyoObjectStructure] = [
            XyoObjectStructure.newInstance(schema: itemOneSchema, bytes: XyoBuffer(data: [0x13, 0x37])),
            XyoObjectStructure.newInstance(schema: itemTwoSchema, bytes: XyoBuffer(data: [0x13, 0x37]))
        ]

        let itemToAdd = XyoObjectStructure.newInstance(schema: itemOneSchema, bytes: XyoBuffer(data: [0x13, 0x37]))

        let expectedIterable: [UInt8] = [0x30, 0xff, // root header
                                         0x0c,       // size of entire array
                                         0x00, 0x55, // header for all elements
                                         0x03,       // size of element [0]
                                         0x13, 0x37, // value of element [0]
                                         0x03,       // size of element [1]
                                         0x13, 0x37,
                                         0x03,       // size of element [1]
                                         0x13, 0x37] // value of element [1]

        let createdSet = try XyoIterableStructure.createTypedIterableObject(schema: iterableSchema, values: values)

        try createdSet.addElement(element: itemToAdd)

        print(createdSet.getBuffer().toByteArray().toHexString())

        XCTAssertEqual(createdSet.value.toByteArray(), expectedIterable)
    }

    func testValidateTrue () throws {
        let rawBytes = "60020214201574201944000C415974B572A832CB601FBDAEC67E912BA9671B771E032E8F82BD97E9A2D57B7F05A222F820415A132CEE730579B7B245D97E58354EC304C64D97D3E6B4A77AE7213008240010217FBC8759E2B6AE0A12ADCBB6ABEEF342219AFDC495C8D920072AE09C784DCED800030500000E0520155C300624001021F45D1235377FDE3C42FF7953F6579A1C57164D24FAAFD643D332179D9F56675F3008240010217FBC8759E2B6AE0A12ADCBB6ABEEF342219AFDC495C8D920072AE09C784DCED800030500000101201906000E0300002017EF2005E42002E1201574201944000C415974B572A832CB601FBDAEC67E912BA9671B771E032E8F82BD97E9A2D57B7F05A222F820415A132CEE730579B7B245D97E58354EC304C64D97D3E6B4A77AE7213008240010215BF936EEDE11E006D9E2A0E2FD4EAEBB8F2B648C949F8E8DEEE1C9B6F4611D9C00030500000D0420151000030500000000201906000E030000201709201A06000B03000020174B201A4800094521008285A4FA3933F42CBE16967CDFA2C05799976E8BA5E28E071A1990C59510E3642100C192599BE091DE79CA25BE6F0D31B76653F91142E3541A98CD5261836C0D802C201A06000B03000020174B201A480009452100FCFB0708A2503595F14F12855D52C62570C5BB7E90635AC2B85C9B206A18D2492100D2A52F6A3F338C32D58EE89E432065B0D876ECB39FB1C34F41E2B3C1D74FCC99".hexStringToBytes()

        let structurer = XyoIterableStructure(value: XyoBuffer(data: rawBytes))
        let iterator = try structurer.getNewIterator()

        while try iterator.hasNext() {
            let item = try iterator.next()
            print(item.getBuffer().toByteArray().toHexString())
        }

        try XyoIterableStructure.verify(item: structurer)
    }

    func testValidateFalse () throws {
        let rawBytes = "600201A22015CB2019C8000C41170F9302323929FD3FD8A72851F73866A0BFC6D488040E9D921689E01B9E25E4393B0984576763DD9C5DA95E609A80B4CC12064758C1AEEE28AE264015BF474F000D8200AEB335766EC511499DDE566579B4ED1562079AA543388B2EDED68ED68363AE9DAE25E7E29B9A5607E670FF234B98891EE3FF99365A3CA6AB804173F1A8619934134A68F59FBDCA92E200C04A196D4A39C987C984E18B79D3EE81667DD92E962E6C630DB5D7BDCDB1988000A81713AB83E5D8B4EF6D2EAB4D70B61AADCA01E733CB0B3D072DE307CDBCD09F46D528A7159EB73DEBB018871E30D182F5BBB426689E758A7BFD4C51D0AD116CA621BF1C39DA49A837D525905D22BAB7C1874F6C7E6B4D56139A15C3BE1D1DC8E061C241C060A24B588217E37D6206AFE5D71F4698D42E25C4FCE996EECCF7690B900130200".hexStringToBytes()

        let structurer = XyoIterableStructure(value: XyoBuffer(data: rawBytes))

        do {
            try XyoIterableStructure.verify(item: structurer)
        } catch is XyoObjectError {
            return
            // this is expected
        }

        throw XyoObjectError.OUTOFINDEX
    }

}
