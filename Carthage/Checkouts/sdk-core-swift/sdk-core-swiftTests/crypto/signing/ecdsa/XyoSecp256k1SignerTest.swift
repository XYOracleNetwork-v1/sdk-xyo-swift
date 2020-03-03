//
//  XyoSecp256k1SignerTest.swift
//  sdk-core-swiftTests
//
//  Created by Carter Harrison on 2/25/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import XCTest
import sdk_core_swift

class XyoSecp256k1SignerTest: XCTestCase {
    
    func testGetPublicKey () throws {
        let privateKey = "DECCC9FA76EF2D0D90D5C5C9807C25E5429C5202D35A8F5D5C9A3CD7DE0B26EF".hexStringToBytes()
        let publicKey = "DC26168A6630A280E7152FD2749F60BC59EDAC0544276B7F55C91FC57141E4E510D55149DEB84941BC68EC863A9288A65EB485B631F08BD9DC0AA65F5F5E2D12".hexStringToBytes()
        
        let signer = XyoSecp256k1Signer(privateKeyNum: privateKey)
        let cPublicKey = signer.getPublicKey()
        
        XCTAssertEqual(try cPublicKey.getValueCopy().toByteArray(), publicKey)
    }
    
    func testSign () throws {
        let privateKey = "DECCC9FA76EF2D0D90D5C5C9807C25E5429C5202D35A8F5D5C9A3CD7DE0B26EF".hexStringToBytes()
        let signer = XyoSecp256k1Signer(privateKeyNum: privateKey)
        
        _ = signer.sign(data: [0x00])
        // must assert with auth because sigs are non-deterministic
    }
    
}
