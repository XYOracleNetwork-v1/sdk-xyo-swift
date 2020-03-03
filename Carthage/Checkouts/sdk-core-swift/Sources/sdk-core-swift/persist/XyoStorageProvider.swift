//
//  XyoStorageProviderInterface.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public protocol XyoStorageProvider {
    func write (key : [UInt8], value: [UInt8]) throws
    func read (key : [UInt8]) throws -> [UInt8]?
    func delete (key : [UInt8]) throws
    func containsKey (key : [UInt8]) throws -> Bool
}
