//
//  XyoZigZigBoundWitnessTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 1/24/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
@testable import sdk_core_swift

class XyoZigZagBoundWitnessTest: XCTestCase {
    
    func testSinglePartyBoundWitness () throws {
        let signers = [XyoStubSigner()]
        let boundWitness = try XyoZigZagBoundWitness(signers: signers, signedPayload: [], unsignedPayload: [])
        
        _ = try boundWitness.incomingData(transfer: nil, endpoint: true)
        
        XCTAssertEqual(1, try boundWitness.getNumberOfParties())
        XCTAssertEqual(1, try boundWitness.getNumberOfWitnesses())
        XCTAssertEqual(1, try boundWitness.getNumberOfFetters())
        XCTAssert(try boundWitness.getIsCompleted())
    }
    
    func testTwoPartyBoundWitness () throws {
        let signersAlice = [XyoStubSigner()]
        let signersBob = [XyoStubSigner()]
        let boundWitnessAlice = try XyoZigZagBoundWitness(signers: signersAlice, signedPayload: [], unsignedPayload: [])
        let boundWitnessBob = try XyoZigZagBoundWitness(signers: signersBob, signedPayload: [], unsignedPayload: [])
    
        let aliceToBobOne = try boundWitnessAlice.incomingData(transfer: nil, endpoint: false)
        let bobToAliceOne = try boundWitnessBob.incomingData(transfer: aliceToBobOne, endpoint: true)
        
        XCTAssertFalse(try boundWitnessAlice.getIsCompleted())
        XCTAssertFalse(try boundWitnessBob.getIsCompleted())
        
        let aliceToBobTwo = try boundWitnessAlice.incomingData(transfer: bobToAliceOne, endpoint: false)
        _ = try boundWitnessBob.incomingData(transfer: aliceToBobTwo, endpoint: false)
        
        XCTAssertEqual(2, try boundWitnessAlice.getNumberOfParties())
        XCTAssertEqual(2, try boundWitnessAlice.getNumberOfWitnesses())
        XCTAssertEqual(2, try boundWitnessAlice.getNumberOfFetters())
        XCTAssert(try boundWitnessAlice.getIsCompleted())
        
        XCTAssertEqual(2, try boundWitnessBob.getNumberOfParties())
        XCTAssertEqual(2, try boundWitnessBob.getNumberOfWitnesses())
        XCTAssertEqual(2, try boundWitnessBob.getNumberOfFetters())
        XCTAssert(try boundWitnessBob.getIsCompleted())
        
        XCTAssertEqual(boundWitnessBob.getBuffer().toByteArray(), boundWitnessAlice.getBuffer().toByteArray())
    
    }
    
    
}
