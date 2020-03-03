//
//  XyoSigner.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/22/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public protocol XyoSigner {
    func getPublicKey () -> XyoObjectStructure
    func getPrivateKey () -> XyoObjectStructure
    func sign (data : [UInt8]) -> XyoObjectStructure
}
