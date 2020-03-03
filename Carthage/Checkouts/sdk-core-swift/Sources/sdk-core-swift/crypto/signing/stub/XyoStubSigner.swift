//
//  XyoStubSigner.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/22/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public class XyoStubSigner : XyoSigner {
    private let stubKeyValue : [UInt8]
    private let stubSignatureValue : [UInt8]
    private let stubPrivateKeyValue : [UInt8]
    
    public init () {
        self.stubKeyValue = [0x00, 0x00]
        self.stubSignatureValue = [0x00, 0x00]
        self.stubPrivateKeyValue = [0x00, 0x00]
    }
    
    public init (stubKeyValue : [UInt8], stubSignatureValue: [UInt8], stubPrivateKeyValue: [UInt8]) {
        self.stubKeyValue = stubKeyValue
        self.stubSignatureValue = stubSignatureValue
        self.stubPrivateKeyValue = stubPrivateKeyValue
                
    }
    
    public func getPublicKey () -> XyoObjectStructure {
        return XyoObjectStructure.newInstance(schema: XyoSchemas.STUB_PUBLIC_KEY, bytes: XyoBuffer(data: stubKeyValue))
    }
    
    public func getPrivateKey () -> XyoObjectStructure {
        return XyoObjectStructure.newInstance(schema: XyoSchemas.STUB_PRIVATE_KEY, bytes: XyoBuffer(data: stubPrivateKeyValue))
    }
    
    public func sign (data : [UInt8]) -> XyoObjectStructure {
        return XyoObjectStructure.newInstance(schema: XyoSchemas.STUB_SIGNATURE, bytes: XyoBuffer(data: stubSignatureValue))
    }
}
