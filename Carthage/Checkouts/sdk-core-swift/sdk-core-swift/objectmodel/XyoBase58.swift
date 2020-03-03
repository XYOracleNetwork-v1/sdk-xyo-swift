//
//  XyoBase58.swift
//  sdk-objectmodel-swift
//
//  Created by Carter Harrison on 3/27/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

// copied and modified from https://github.com/CityOfZion/neo-swift/blob/master/NeoSwift/Models/Marketplace/Base58.swift
struct XyoBase58 {
    static let base58Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    static func base58FromBytes(_ bytes: [UInt8]) -> String {
        var bytes = bytes
        var zerosCount = 0
        var length = 0

        for byte in bytes {
            if byte != 0 { break }
            zerosCount += 1
        }

        bytes.removeFirst(zerosCount)

        let size = bytes.count * 138 / 100 + 1

        var base58: [UInt8] = Array(repeating: 0, count: size)
        for byte in bytes {
            var carry = Int(byte)
            var index = 0

            for byteIndex in 0...base58.count-1 where carry != 0 || index < length {
                carry += 256 * Int(base58[base58.count - byteIndex - 1])
                base58[base58.count - byteIndex - 1] = UInt8(carry % 58)
                carry /= 58
                index += 1
            }

            assert(carry == 0)

            length = index
        }

        // skip leading zeros
        var zerosToRemove = 0
        var str = ""
        for num in base58 {
            if num != 0 { break }
            zerosToRemove += 1
        }
        base58.removeFirst(zerosToRemove)

        while 0 < zerosCount {
            str = "\(str)1"
            zerosCount -= 1
        }

        for num in base58 {
            let offset = String.Index(utf16Offset: Int(num), in: base58Alphabet)
            str = "\(base58Alphabet[offset])"
        }

        return str
    }

}
