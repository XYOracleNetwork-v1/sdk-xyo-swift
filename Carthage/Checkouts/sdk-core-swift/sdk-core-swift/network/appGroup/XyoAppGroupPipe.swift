//
//  XyoAppGroupPipe.swift
//  sdk-core-swift
//
//  Created by Darren Sutherland on 5/31/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

/// Uses a shared file between the same app group to transmit data between apps
public class XyoAppGroupPipe {

    public typealias SendCompletionHandler = ([UInt8]?) -> ()

    // The connection wrangler, a ref is saved to be used when the pipe closes
    fileprivate weak var manager: XyoAppGroupManagerListener?

    // The return handler for the pipe
    fileprivate var completionHandler: SendCompletionHandler?

    // Initial data
    fileprivate var initiationData : XyoAdvertisePacket?

    // Handles file management so inter-app communication can occur
    fileprivate var fileManager: XyoSharedFileManager?

    // The identifier of the app, used as the filename for the pipe
    fileprivate let identifier: String

    // Used by the "server" to remove the pipe
    fileprivate var requestorIdentifier: String?

    // Handles initiation data transmission
    fileprivate var firstWrite: (() -> Void)?
    fileprivate var completedFirstWrite: Bool = false

    public init(groupIdentifier: String, identifier: String, pipeName: String, manager: XyoAppGroupManagerListener,
                requestorIdentifier: String? = nil, initiationData : XyoAdvertisePacket? = nil) {

        self.initiationData = initiationData
        self.identifier = identifier

        self.manager = manager
        self.requestorIdentifier = requestorIdentifier

        // Create the filemanager and listen for write changes to the pipe file
        self.fileManager = XyoSharedFileManager(for: identifier, filename: pipeName, groupIdentifier: groupIdentifier)
        self.fileManager?.setReadListenter(self.listenForResponse)
    }

    internal func setCompletionHandler(_ handler: SendCompletionHandler?) {
        self.completionHandler = handler
    }

    public func setFirstWrite(_ callback: @escaping () -> Void) {
        self.firstWrite = callback
    }

    // We need to nil out the various callbacks and the filemanager so the pipe can be cleaned up by ARC
    internal func cleanup() {
        self.completionHandler = nil
        self.fileManager = nil
        self.initiationData = nil
        self.firstWrite = nil
    }

}

// MARK: XyoNetworkPipe
extension XyoAppGroupPipe: XyoNetworkPipe {

    public func getInitiationData() -> XyoAdvertisePacket? {
        return initiationData
    }

    public func getNetworkHeuristics() -> [XyoObjectStructure] {
        return []
    }

    public func send(data: [UInt8], waitForResponse: Bool, completion: @escaping ([UInt8]?) -> ()) {
        // Write to the pipe file, which will trigger the completion handler
        self.fileManager?.write(data: data) { error in
            guard error == nil else {
                completion(nil)
                return
            }

            // If we wait for a response then set the completion handler
            if waitForResponse {
                self.completionHandler = completion
            } else {
                // Notify the other end we are all done
                completion(nil)
            }
        }
    }

    public func close() {
        self.manager?.onClose(identifier: self.requestorIdentifier)
    }

}

// MARK: Handles the response from the other side of the pipe
fileprivate extension XyoAppGroupPipe {

    func listenForResponse(_ data: [UInt8]?, identifier: String) {
        // If this isn't the first write to the pipe, the pipe responds back with the data
        if completedFirstWrite || firstWrite == nil {
            self.completionHandler?(data)
            return
        }

        // Otherwise, we initiate the first write to the pipe
        if let data = data {
            self.initiationData = XyoAdvertisePacket(data: data)
            self.completedFirstWrite = true
            self.firstWrite?()
        }
    }

}
