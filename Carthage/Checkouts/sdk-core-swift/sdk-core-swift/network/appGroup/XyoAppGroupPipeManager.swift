//
//  XyoAppGroupManager.swift
//  sdk-core-swift
//
//  Created by Darren Sutherland on 5/31/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public protocol XyoAppGroupPipeListener {
    func onPipe (pipe: XyoNetworkPipe)
    func complete()
}

public protocol XyoAppGroupManagerListener: class {
    func onClose (identifier : String?)
}

/// Allows for a client to request a pipe be created to connect to a server
public class XyoAppGroupPipeServer {

    // Registry of pipes
    fileprivate lazy var pipes = [String: XyoAppGroupPipe]()

    fileprivate struct Constants {
        static let fileExtension = "xyonetwork"
        static let serverIdentifier = "server"
    }

    fileprivate let listener: XyoAppGroupPipeListener

    fileprivate let groupIdentifier: String

    public init(listener: XyoAppGroupPipeListener, groupIdentifier: String = XyoSharedFileManager.defaultGroupId) {
        self.groupIdentifier = groupIdentifier

        // Notifies on the addition of a new pipe
        self.listener = listener
    }

    // Called from the client to ask for a pipe to be created for this connection
    public func prepareConnection(identifier: String) -> XyoAppGroupPipe {
        // Build the pipe
        let pipe = XyoAppGroupPipe(
            groupIdentifier: self.groupIdentifier,
            identifier: identifier,
            pipeName: identifier,
            manager: self,
            requestorIdentifier: identifier)

        self.pipes[identifier] = pipe

        return pipe
    }

    // Called from the server to start the transfer
    public func transfer(to identifier: String) {
        guard self.pipes[identifier] == nil else { return }

        // Build the pipe for talking to the client
        let pipe = XyoAppGroupPipe(
            groupIdentifier: self.groupIdentifier,
            identifier: Constants.serverIdentifier,
            pipeName: identifier,
            manager: self,
            requestorIdentifier: identifier)

        // Track the pipe
        self.pipes[identifier] = pipe

        // Notify the listener
        self.listener.onPipe(pipe: pipe)
    }

}

extension XyoAppGroupPipeServer: XyoAppGroupManagerListener {

    // Called when the pipe is released via it's close() method
    public func onClose(identifier: String?) {
        guard
            let identifier = identifier,
            let pipe = self.pipes[identifier] else { return }

        pipe.cleanup()

        self.pipes.removeValue(forKey: identifier)

        self.listener.complete()
    }

}
