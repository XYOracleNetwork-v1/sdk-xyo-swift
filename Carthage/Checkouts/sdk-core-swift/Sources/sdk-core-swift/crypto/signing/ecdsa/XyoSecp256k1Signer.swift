//
//  XyoSecp256k1Signer.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 2/25/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import secp256k1

public class XyoSecp256k1Signer : XyoSigner {
    private var privateKey : [UInt8]
    private let secp256k1SignContext : OpaquePointer
    private let secp256k1VerifyContext : OpaquePointer
    private var publicKey : secp256k1_pubkey = secp256k1_pubkey.init()
    
    public init (privateKeyNum : [UInt8]) {
        self.privateKey = privateKeyNum
        self.secp256k1SignContext = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))
        self.secp256k1VerifyContext = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY))
        
        _ = secp256k1_ec_pubkey_create(secp256k1SignContext, &publicKey, &privateKey)
    }

    public convenience init () {
        var priv = [UInt8]()
        priv.append(contentsOf: XyoSecp256k1Signer.randomData(ofLength: 32))
        
        self.init(privateKeyNum: priv)
    }
    
    public func getPublicKey () -> XyoObjectStructure {
        var out = [UInt8].init(repeating: 0, count: 65)
        var size = 65
        secp256k1_ec_pubkey_serialize(secp256k1SignContext, &out, &size, &publicKey, UInt32(SECP256K1_EC_UNCOMPRESSED))
        out.remove(at: 0)
        return XyoObjectStructure.newInstance(schema: XyoSchemas.EC_PUBLIC_KEY, bytes: XyoBuffer(data: out))
    }
    
    public func getPrivateKey () -> XyoObjectStructure {
        return XyoObjectStructure.newInstance(schema: XyoSchemas.EC_PRIVATE_KEY, bytes: XyoBuffer(data: privateKey))
    }
    
    public func sign (data : [UInt8]) -> XyoObjectStructure {
        var length = 100
        var out = [UInt8].init(repeating: 0, count: length)
        var sig = secp256k1_ecdsa_signature.init()
        var nonce = XyoSecp256k1Signer.randomData(ofLength: 32)
        
        secp256k1_ecdsa_sign(secp256k1SignContext, &sig, hashTo32BytesSha256(data: data), &privateKey, secp256k1_nonce_function_default, &nonce)
        secp256k1_ecdsa_signature_serialize_der(secp256k1SignContext, &out, &length, &sig)
        
        let buffer = XyoBuffer()
            .put(bits: out[3])
            .put(bytes: getRFromD(der: out))
            .put(bits: out[Int(5 + out[3])])
            .put(bytes: getSFromD(der: out))
        
        return XyoObjectStructure.newInstance(schema: XyoSchemas.EC_SIGNATURE, bytes: buffer)
    }
    
    private func getRFromD(der : [UInt8]) -> [UInt8] {
        let sizeOfR = Int(der[3])
        let buffer = XyoBuffer(data: der)
        return buffer.copyRangeOf(from: 3 + 1, toEnd: (3 + sizeOfR) + 1).toByteArray()
    }
    
    private func getSFromD(der : [UInt8]) -> [UInt8] {
        let sizeOfR = Int(der[3])
        let sizeOfS = Int(der[Int(5 + sizeOfR)])
        let buffer = XyoBuffer(data: der)
        return buffer.copyRangeOf(from: 5 + sizeOfR + 1, toEnd: 6 + sizeOfR + sizeOfS).toByteArray()
    }
    
    private static func randomData(ofLength length: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        if status == errSecSuccess {
            return Data(bytes)
        }
        fatalError()
    }
    
    private func hashTo32BytesSha256 (data : [UInt8]) -> [UInt8] {
        do {
             return try XyoSha256().hash(data: data).getValueCopy().toByteArray()
        } catch {
            fatalError()
        }
    }
}
