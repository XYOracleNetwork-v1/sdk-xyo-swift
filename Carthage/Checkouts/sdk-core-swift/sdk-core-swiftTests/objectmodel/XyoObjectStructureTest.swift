//
//  XyoObjectStructureTest.swift
//  sdk-objectmodel-swiftTests
//
//  Created by Carter Harrison on 1/21/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoObjectStructureTest: XCTestCase {

    func testGetBuffer () {
        let schema = XyoObjectSchema.create(id: 0xff,
                                            isIterable: false,
                                            isTypedIterable: false,
                                            sizeIdentifier: XyoObjectSize.ONE)
        let structure = XyoObjectStructure.newInstance(schema: schema, bytes: XyoBuffer(data: [0x13, 0x37]))

        XCTAssertEqual(structure.getBuffer().toByteArray(), [0x00, 0xff, 0x03, 0x13, 0x37])
    }

    func testGetValue () throws {
        let schema = XyoObjectSchema.create(id: 0xff,
                                            isIterable: false,
                                            isTypedIterable: false,
                                            sizeIdentifier: XyoObjectSize.ONE)
        let structure = XyoObjectStructure.newInstance(schema: schema, bytes: XyoBuffer(data: [0x13, 0x37]))

        XCTAssertEqual(try structure.getValueCopy().toByteArray(), [0x13, 0x37])
    }

    func testGetValueLong () throws {
        let rawBytes = "6002012B201547201944000C4192BAF8FBA41F6B5CA997DF7634F1F33176E0DDA8F7B485C6CD2EBC3BA06D4EEC8BB98284DB33761BA8A7668D1A5C140384968A0BE3436067F10A0D6B7F5AAFFF201547201944000C41ED1512DA596726D8E19A592BBA5573D31174C424FDFD7A0D14B3088BD22F0EB520F99E19D78DBBD613B79277FEB2BD0911C4C379E69B8688CC744B5B5ACF928F20174A201A470009442100CAC1C5F12BCCEA80C176FCCEEFEC616E86A9F208F43E45D49E8F32F76278B9F8202ABFC11D935F56D5CFECFDC66D4CA37D67C69AE6CD3C1DB41794C3C7FF41FE90201749201A4600094320656984EF23EAD4304E4A1AB3321F64BF9629FFE0E3A4097B181C2295892578D2205B90DAD8607D3BE600209771E2A19EC9EA3BB7BEE9D44A99395E85577FBCDBB7".hexStringToBytes()

        let structurer = XyoIterableStructure(value: XyoBuffer(data: rawBytes))

        _ = try structurer.getValueCopy()
    }

}
