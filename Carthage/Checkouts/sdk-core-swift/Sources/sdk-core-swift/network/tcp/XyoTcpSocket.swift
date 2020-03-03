//
//  TcpTest.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/29/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public class XyoTcpSocket : NSObject, StreamDelegate {
    private static let MAX_READ_SIZE_K_BYTES = 200
    private var clientContext = CFStreamClientContext()
    private let writeStream : OutputStream
    private let readStream : InputStream
    
    init (writeStream : OutputStream!, readStream : InputStream!) {
        self.readStream = readStream
        self.writeStream = writeStream
        
       
        
        CFWriteStreamSetClient(writeStream,
                               XyoTcpSocket.allCFFlags,
                               writeCallback,
                               &clientContext)
        
        CFReadStreamSetClient(readStream,
                              XyoTcpSocket.allCFFlags,
                              readCallback,
                              &clientContext)
        
        super.init()
        
        writeStream.schedule(in: .main, forMode: RunLoop.Mode.common)
        readStream.schedule(in: .main, forMode: RunLoop.Mode.common)
    }
    
    let writeCallback:CFWriteStreamClientCallBack = {(stream:CFWriteStream?, eventType:CFStreamEventType, info:UnsafeMutableRawPointer?) in
    
    }
    
    let readCallback:CFReadStreamClientCallBack = {(stream:CFReadStream?, eventType:CFStreamEventType, info:UnsafeMutableRawPointer?) in
        
    }
    
    public func openWriteStream() {
        self.writeStream.open()
    }
    
    public func openReadStream () {
        self.readStream.open()
    }
    
    public func closeWriteStream() {
        self.writeStream.close()
    }
    
    public func closeReadStream() {
        self.readStream.close()
    }
    
    public func write (bytes : [UInt8], canBlock : Bool) -> Bool {
        let pointer = UnsafePointer<UInt8>(bytes)
        
        if (self.writeStream.hasSpaceAvailable || canBlock) {
             return self.writeStream.write(pointer, maxLength: bytes.count) == bytes.count
        }
        
        return false
    }
    
    public func read (size : Int, canBlock : Bool) -> [UInt8]? {
        if (size > (XyoTcpSocket.MAX_READ_SIZE_K_BYTES * 1024)) {
            return nil
        }
        
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        
        if(self.readStream.hasBytesAvailable || canBlock) {
            if (self.readStream.read(pointer, maxLength: size) == -1) {
                return nil
            }
            
             return Array(UnsafeMutableBufferPointer(start: pointer, count: size))
        }
    
        return nil
    }
    
    
    public static func create(peer : XyoTcpPeer) -> XyoTcpSocket {
        var readStream : Unmanaged<CFReadStream>?
        var writeStream : Unmanaged<CFWriteStream>?
        let host : CFString = NSString(string: peer.ip)
        let port : UInt32 = UInt32(peer.port)
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &readStream, &writeStream)
        
        return XyoTcpSocket(writeStream: writeStream?.takeRetainedValue(), readStream: readStream!.takeRetainedValue())
        
    }
    
    private static let allCFFlags = CFOptionFlags(CFStreamEventType.openCompleted.rawValue |
        CFStreamEventType.hasBytesAvailable.rawValue |
        CFStreamEventType.endEncountered.rawValue |
        CFStreamEventType.errorOccurred.rawValue)
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.endEncountered:
            closeReadStream()
            closeReadStream()
        default:
            break
        }
    }
}
