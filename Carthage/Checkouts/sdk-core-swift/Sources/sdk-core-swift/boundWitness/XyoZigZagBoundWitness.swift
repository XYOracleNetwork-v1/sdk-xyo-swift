//
//  XyoZigZagBoundWitness.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/23/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

class XyoZigZagBoundWitness : XyoBoundWitness {
    private let signers : [XyoSigner]
    private let signedPayload : [XyoObjectStructure]
    private let unsignedPayload : [XyoObjectStructure]
    private var hasSentFetter = false
    
    init(signers: [XyoSigner], signedPayload: [XyoObjectStructure], unsignedPayload: [XyoObjectStructure]) throws {
        self.signers = signers
        self.signedPayload = signedPayload
        self.unsignedPayload = unsignedPayload
        
        super.init(value: XyoIterableStructure.encodeUntypedIterableObject(schema: XyoSchemas.BW, values: []))
    }
    
    public func incomingData (transfer : XyoIterableStructure?, endpoint: Bool) throws -> XyoIterableStructure  {
        if (transfer != nil) {
            try addTransfer(transfer: transfer.unsafelyUnwrapped)
        }
        
        if (!hasSentFetter) {
            let fetter = try XyoBoundWitness.createMasterArrayWithSubArray(masterSchema: XyoSchemas.FETTER,
                                                                           subSchema: XyoSchemas.KEY_SET,
                                                                           masterItems: signedPayload,
                                                                           subItems: getPublicKeysFromSigner())
            
            try addToLedger(item: fetter)
            hasSentFetter = true
        }
        
        if (try getNumberOfFetters() != (try getNumberOfWitnesses())) {
            return try getReturnFromIncomming(numberOfWitnesses: getNumberOfWitnessesFromTransfer(transfer: transfer), endpoint: endpoint)
        }
        
        return try encodeTransfer(items: [])
    }
    
    private func getReturnFromIncomming (numberOfWitnesses : Int, endpoint : Bool) throws -> XyoIterableStructure {
        if (numberOfWitnesses == 0 && !endpoint) {
            var elements = [XyoObjectStructure]()
            let it = try getNewIterator()
            
            while (try it.hasNext()) {
                elements.append(try it.next())
            }
            
            return try encodeTransfer(items: elements)
        }
        
        return try passAndSign(numberOfWitnesses: numberOfWitnesses)
    }

    private func passAndSign (numberOfWitnesses : Int) throws -> XyoIterableStructure {
        var toSendBack = [XyoObjectStructure]()
        
        try signBoundWitness(payload: unsignedPayload)
        
        let fetters = try self.get(id: XyoSchemas.FETTER.id)
        let witnesses = try self.get(id: XyoSchemas.WITNESS.id)
        
        let x = numberOfWitnesses + 1
        let y = fetters.count - 1
        
        if (x <= y) {
            for i in (x...y) {
                toSendBack.append(fetters[i])
            }
        }
        
        
        toSendBack.append(witnesses[witnesses.count - 1])
        
        return try encodeTransfer(items: toSendBack)
    }
    
    private func encodeTransfer (items: [XyoObjectStructure]) throws -> XyoIterableStructure {
        var fetters = [XyoObjectStructure]()
        var witnesses = [XyoObjectStructure]()
        
        for item in items {
            switch (try item.getSchema().id)  {
            case XyoSchemas.WITNESS.id:
                witnesses.append(item)
            case XyoSchemas.FETTER.id:
                fetters.append(item)
            default:
                throw XyoError.MUST_BE_FETTER_OR_WITNESS
            }
        }
        
        return try encodeFettersAndWitnessesForTransfer(fetters: fetters, witnesses: witnesses, items: items)
    }
    
    private func encodeFettersAndWitnessesForTransfer (fetters: [XyoObjectStructure], witnesses: [XyoObjectStructure], items: [XyoObjectStructure]) throws -> XyoIterableStructure {
        if (fetters.count == 0 && witnesses.count != 0) {
            return try XyoIterableStructure.createTypedIterableObject(schema: XyoSchemas.WITNESS_SET, values: witnesses)
        } else if (fetters.count != 0 && witnesses.count == 0) {
            return try XyoIterableStructure.createTypedIterableObject(schema: XyoSchemas.FETTER_SET, values: fetters)
        }
        
        return XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.BW_FRAGMENT, values: items)
    }
    
    private func getNumberOfWitnessesFromTransfer (transfer: XyoIterableStructure?) throws -> Int {
        return (try transfer?.get(id: XyoSchemas.WITNESS.id).count) ?? 0
    }
    
    private func addTransfer (transfer : XyoIterableStructure) throws {
        try XyoIterableStructure.verify(item: transfer)
        
        let it = try transfer.getNewIterator()

        while try it.hasNext() {
            try addToLedger(item: try it.next())
        }
    }
    
    private func getPublicKeysFromSigner () throws -> [XyoObjectStructure] {
        var returnValue = [XyoObjectStructure]()
        
        for signer in signers {
            returnValue.append(signer.getPublicKey())
        }
        
        return returnValue
    }
    
    private func signBoundWitness (payload : [XyoObjectStructure]) throws {
        var signatures = [XyoObjectStructure]()
        
        for signer in signers {
            signatures.append(try signCurrent(signer: signer))
        }
        
        let witness = XyoBoundWitness.createMasterArrayWithSubArray(masterSchema: XyoSchemas.WITNESS,
                                                                    subSchema: XyoSchemas.SIGNATURE_SET,
                                                                    masterItems: unsignedPayload,
                                                                    subItems: signatures)
        try addToLedger(item: witness)
    }
}
