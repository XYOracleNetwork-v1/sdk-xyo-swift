//
//  XyoOriginBlockRepositoryTests.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

struct XyoOriginBlockRepositoryTests {
    static let expectedHashOne = "00102123B04C77DD8DBFFEF14251293DA9FF845C2294BCA5F4F56469C22D2E4EFDE49C".hexStringToBytes()
    static let boundWitnessOne = XyoBoundWitness(value: XyoBuffer(data: "6002012B201547201944000C4192BAF8FBA41F6B5CA997DF7634F1F33176E0DDA8F7B485C6CD2EBC3BA06D4EEC8BB98284DB33761BA8A7668D1A5C140384968A0BE3436067F10A0D6B7F5AAFFF201547201944000C41ED1512DA596726D8E19A592BBA5573D31174C424FDFD7A0D14B3088BD22F0EB520F99E19D78DBBD613B79277FEB2BD0911C4C379E69B8688CC744B5B5ACF928F20174A201A470009442100CAC1C5F12BCCEA80C176FCCEEFEC616E86A9F208F43E45D49E8F32F76278B9F8202ABFC11D935F56D5CFECFDC66D4CA37D67C69AE6CD3C1DB41794C3C7FF41FE90201749201A4600094320656984EF23EAD4304E4A1AB3321F64BF9629FFE0E3A4097B181C2295892578D2205B90DAD8607D3BE600209771E2A19EC9EA3BB7BEE9D44A99395E85577FBCDBB7".hexStringToBytes()))
    
    static func testAdd (blockRepo : XyoOriginBlockRepository) throws {
        XCTAssertFalse(try blockRepo.containsOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne))
        try blockRepo.addOriginBlock(originBlock: XyoOriginBlockRepositoryTests.boundWitnessOne)
        XCTAssertTrue(try blockRepo.containsOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne))
    }
    
    static func testGet (blockRepo : XyoOriginBlockRepository) throws {
        XCTAssertFalse(try blockRepo.containsOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne))
        try blockRepo.addOriginBlock(originBlock: XyoOriginBlockRepositoryTests.boundWitnessOne)
        XCTAssertTrue(try blockRepo.containsOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne))
        
        guard let readValue = try blockRepo.getOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne) else {
            throw XyoError.EXTREME_TESTING_ERROR
        }
        
        XCTAssertEqual(boundWitnessOne.getBuffer().toByteArray(), readValue.getBuffer().toByteArray())
    }
    
    static func testContains (blockRepo : XyoOriginBlockRepository) throws {
        XCTAssertFalse(try blockRepo.containsOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne))
        try blockRepo.addOriginBlock(originBlock: XyoOriginBlockRepositoryTests.boundWitnessOne)
        XCTAssertTrue(try blockRepo.containsOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne))
        
        guard let readValue = try blockRepo.getOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne) else {
            throw XyoError.EXTREME_TESTING_ERROR
        }
        
        XCTAssertEqual(boundWitnessOne.getBuffer().toByteArray(), readValue.getBuffer().toByteArray())
        try blockRepo.removeOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne)
        
        XCTAssertNil(try blockRepo.getOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne))
        XCTAssertFalse(try blockRepo.containsOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne))
    }
    
    static func testRemove (blockRepo : XyoOriginBlockRepository) throws {
        XCTAssertFalse(try blockRepo.containsOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne))
        try blockRepo.addOriginBlock(originBlock: XyoOriginBlockRepositoryTests.boundWitnessOne)
        XCTAssertTrue(try blockRepo.containsOriginBlock(originBlockHash: XyoOriginBlockRepositoryTests.expectedHashOne))
    }
    
}
