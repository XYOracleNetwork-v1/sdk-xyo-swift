//
//  XyoZigZagBoundWitnessSession.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/24/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

class XyoZigZagBoundWitnessSession: XyoZigZagBoundWitness {
    private static let maxNumberOfCycles = 10
    private var cycles = 0
    private let handler : XyoNetworkHandler
    private let choice : [UInt8]
    
    init(signers: [XyoSigner],
         signedPayload: [XyoObjectStructure],
         unsignedPayload: [XyoObjectStructure],
         handler : XyoNetworkHandler,
         choice : [UInt8]) throws {
        
        self.handler = handler
        self.choice = choice
        
        try super.init(signers: signers, signedPayload: signedPayload, unsignedPayload: unsignedPayload)
    }
    
    public func doBoundWitness (transfer: XyoIterableStructure?, completion : @escaping (_: XyoError?)->()?) {
        do {
            if (cycles >= XyoZigZagBoundWitnessSession.maxNumberOfCycles) {
                completion(XyoError.UNKNOWN_ERROR)
                return
            }
            
            if (try !getIsCompleted()) {
                try sendAndReceive(didHaveData: transfer != nil, transfer: transfer) { response in
                    do {
                        if (self.cycles == 0 && transfer != nil && response == nil) {
                            throw XyoError.RESPONSE_IS_NULL
                        }
                        
                        if (self.cycles == 0 && transfer != nil && response != nil) {
                            _ = try self.incomingData(transfer: response, endpoint: false)
                            completion(nil)
                            return
                        }
                        
                        self.cycles += 1
                        self.doBoundWitness(transfer: response, completion: completion)
                        return
                    } catch is XyoObjectError {
                        completion(XyoError.BYTE_ERROR)
                        return
                    } catch {
                        completion(XyoError.UNKNOWN_ERROR)
                        return
                    }
                }
            } else {
                completion(nil)
            }
        } catch {
            completion(XyoError.UNKNOWN_ERROR)
        }
    }
    

    private func sendAndReceive (didHaveData: Bool, transfer: XyoIterableStructure?, completion: @escaping (_ : XyoIterableStructure?)->()) throws {
        let returnData = try incomingData(transfer: transfer, endpoint: (cycles == 0 && didHaveData))
        
        if (cycles == 0 && !didHaveData) {
            try sendAndReceiveWithChoice(returnData : returnData, transfer: transfer, completion: completion)
            return
        }
        
        handler.pipe.send(data: returnData.getBuffer().toByteArray(), waitForResponse: cycles == 0) { result in
            guard let response = result else {
                completion(nil)
                return
            }
            
            completion(XyoIterableStructure(value: XyoBuffer(data: response)))
            
        }
    }
    
    private func sendAndReceiveWithChoice (returnData: XyoIterableStructure, transfer: XyoIterableStructure?, completion: @escaping (_ : XyoIterableStructure?)->()) throws {
        handler.sendChoicePacket(catalogue: choice, response: returnData.getBuffer().toByteArray()) { result in
            guard let response = result else {
                completion(nil)
                return
            }
            
            completion( XyoIterableStructure(value: XyoBuffer(data: response)))
        }
    }
}
