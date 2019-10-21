[logo]: https://cdn.xy.company/img/brand/XY_Logo_GitHub.png

![logo]

# sdk-xyo-swift

[![](https://travis-ci.org/XYOracleNetwork/sdk-core-swift.svg?branch=master)](https://travis-ci.org/XYOracleNetwork/sdk-xyo-swift)[![Codacy Badge](https://api.codacy.com/project/badge/Grade/2fb2eb69c1db455299ffce57b0216aa6)](https://www.codacy.com/app/XYOracleNetwork/sdk-xyo-swift?utm_source=github.com&utm_medium=referral&utm_content=XYOracleNetwork/sdk-xyo-swift&utm_campaign=Badge_Grade) [![Maintainability](https://api.codeclimate.com/v1/badges/af641257b27ecea22a9f/maintainability)](https://codeclimate.com/github/XYOracleNetwork/sdk-xyo-swift/maintainability) [![](https://img.shields.io/gitter/room/XYOracleNetwork/Stardust.svg)](https://gitter.im/XYOracleNetwork/Dev)

## Table of Contents

-   [Title](#sdk-xyo-swift)
-   [Description](#description)
-   [Usage](#usage)
-   [Architecture](#architecture)
-   [Maintainers](#maintainers)
-   [Contributing](#contributing)
-   [License](#license)
-   [Credits](#credits)

## Description 

A high-level SDK for interacting with the XYO network.
Including BLE, TCP/IP, Bound Witnessing, and Bridging. 

## Start Here

Copy this code to test. Look below for specific usage. 

One line is all it takes to start your node 

```swift
let builder = XyoNodeBuilder().setBoundWitnessDelegate(self)
```

For a more complex test, create a listener callback.


You can also configure to your specific roles.

## Usage

Build an XYO Node 

```swift
let builder = XYONodeBuilder()
```

After calling the node builder, you can start the build

```swift
let node = try builder.build()
```

Once you have a build, you have access to properties to help you shape your node and what you want out of it. 

Client

```swift
// select the network
let network = node.networks["this can be "ble" or "tcpip""] as? XyoBleNetwork

// a flag to tell the client to automatically scan
bleNetwork?.client.scan = true
```

These will allow your app to actively seek devices to bound witness with and bridge from the client to the server.

This will return a byteArray.

There are other properties from the client and server which you can find in the source code as well as a reference guide that we have prepared. 

## Architecture

This sdk is built on a client/server to ensure ease of understanding during development. (The client takes on "central" role, and the server the "peripheral"). This allows us to define roles with simplicity. 

> SDK-XYO-swift TREE

-   XyoSDK
    -   mutableList `<XyoNode>` 

        -   `XyoNode(storage, networks)`
            -   `listeners`
                -   `boundWitnessTarget`
        -   XyoClient, XyoServer

            -   Ble

                -   `context`
                -   `relayNode`
                -   `procedureCatalog`
                -   `autoBridge`
                -   `acceptBridging`
                -   `autoBoundWitness`
                -   `scan`

            -   TcpIp
                -   `relayNode`
                -   `procedureCatalog`
                -   `autoBridge`
                -   `acceptBridging`
                -   `autoBoundWitness`

## Sample App

Please refer to the [iOS sample](/Example/iOSExample/XyoExampleViewController.swift) for an exmple implementation for bound witness and bridging. 

### Install

To use the sample app to measure functionality

-   Launch [Xcode](https://developer.apple.com/xcode/)
-   Click on `Open an existing swift Studio Project`
-   Navigate to `<path to the sdk-xyo-swift>/Example/` in your file explorer
-   Open the project workspace `open XyoSdkExample.xcworkspace`

This sample app includes client bridging and bound witnessing with a BLE server listener. 

## Maintainers

-   Kevin Weiler

## License

See the [LICENSE](LICENSE) file for license details.

## Credits

Made with 🔥and ❄️ by [XY - The Persistent Company](https://www.xy.company)

