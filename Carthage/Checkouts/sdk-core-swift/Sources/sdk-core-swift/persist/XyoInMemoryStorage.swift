//
//  XyoInMemoryStorage.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public class XyoInMemoryStorage: XyoStorageProvider {
    private var storageMap = [[UInt8] : [UInt8]]()
    
    public init () {}
    
    public func write (key : [UInt8], value: [UInt8]) throws {
        storageMap[key] = value
    }
    
    public func read (key : [UInt8]) throws -> [UInt8]? {
        return storageMap[key]
    }
    
    public func delete (key : [UInt8]) throws {
        storageMap.removeValue(forKey: key)
    }
    
    public func containsKey (key : [UInt8]) throws -> Bool {
        return storageMap.contains {
            $0.key == key
        }
    }
}
