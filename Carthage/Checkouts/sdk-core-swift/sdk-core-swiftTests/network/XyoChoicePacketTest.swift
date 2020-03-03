//
//  XyoChoicePacketTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 4/29/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//


import Foundation
import XCTest
@testable import sdk_core_swift

class XyoChoicePacketTest : XCTestCase {

    func testGetChoice () throws {
        let bytes: [UInt8] = [0x04, 0x00, 0x00, 0x00, 0x01, 0xff]
        let expected : [UInt8] = [0x00, 0x00, 0x00, 0x01]
        let packet = XyoChoicePacket(data: bytes)

        XCTAssertEqual(try packet.getChoice(), expected)
    }

    func testShouldThrowSafe () throws {
        do {
            let bytes: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x01]
            let packet = XyoChoicePacket(data: bytes)
            _ = try packet.getChoice()
        } catch {

        }
    }
}





