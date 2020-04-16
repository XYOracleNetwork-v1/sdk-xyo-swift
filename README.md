[logo]:https://cdn.xy.company/img/brand/XYO_full_colored.png

[![logo]](https://xyo.network)

# sdk-xyo-swift

![](https://github.com/XYOracleNetwork/sdk-xyo-swift/workflows/Build/badge.svg?branch=develop)
![](https://github.com/XYOracleNetwork/sdk-xyo-swift/workflows/Swift%20PKG%20Release/badge.svg)

[![](https://img.shields.io/cocoapods/v/sdk-xyo-swift.svg?style=flat)](https://cocoapods.org/pods/sdk-xyo-swift) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/6a10ff4a324d4d02a74a7a6724a53eef)](https://www.codacy.com/manual/pllearns/sdk-xyo-swift?utm_source=github.com&utm_medium=referral&utm_content=XYOracleNetwork/sdk-xyo-swift&utm_campaign=Badge_Grade) [![BCH compliance](https://bettercodehub.com/edge/badge/XYOracleNetwork/sdk-xyo-swift?branch=master)](https://bettercodehub.com/) [![Maintainability](https://api.codeclimate.com/v1/badges/eeabbe44d086edf6b032/maintainability)](https://codeclimate.com/github/XYOracleNetwork/sdk-xyo-swift/maintainability)

> The XYO Foundation provides this source code available in our efforts to advance the understanding of the XYO Procotol and its possible uses. We continue to maintain this software in the interest of developer education. Usage of this source code is not intended for production.

## Table of Contents

-   [Title](#sdk-xyo-swift)
-   [Description](#description)
-   [Start Here](#start-here)
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

Include the library in your Podfile 

```Podfile
target 'YourAppName' do
  pod 'sdk-xyo-swift', '1.0.16'

```

Try some code to test. Look below for specific usage. 

One line is all it takes to start your node 

```swift
let builder = XyoNodeBuilder().setBoundWitnessDelegate(self)
```

For a more complex test, create a listener callback.

You can also configure to your specific roles.

## Usage

After creating the node builder, you will create your node with

```swift
let node = try builder.build()
```

Once you have a build, you have access to properties to help you shape your node and what you want out of it. 

Client

```swift
// select the network - examples
let bleNetwork = node.networks["ble"] as? XyoBleNetwork
let tcpipNetwork = node.networks["tcpip"] as? XyoTcpipNetwork

// a flag to tell the client to automatically scan
bleNetwork?.client.scan = true

// a flag to tell the server to listen
bleNetwork?.server.listen = true
```

You can set bridges for the tcp/ip client for bridging. 

```swift
// set local bridges for the tcpip client
tcpipNetwork?.client.knownBridges = ["public address of bridge", "public address of other bridge"]
```
You can set the bound witness delegate

```swift

class SomeViewController: UIViewController, BoundWitnessDelegate {
  func boundWitness(started withDeviceId: String) {
    print("Started BW with (withDeviceId)")
  }

  func boundWitness(completed withDeviceId: String, withBoundWitness: XyoBoundWitness?) {
    print("Completed BW with (withDeviceId)")
  }

}

```

You can also set a string payload data on any node that gets passed in a bound witness

```swift
    class SomeViewController: UIViewController, BoundWitnessDelegate {
        ...
        if var bleClient = (xyoNode?.networks["ble"] as? XyoBleNetwork)?.client {
          bleClient.pollingInterval = 10
          bleClient.stringHeuristic = "Hi I'm Client"
        }
        
        if var bleServer = (xyoNode?.networks["ble"] as? XyoBleNetwork)?.server {
          bleServer.stringHeuristic = "Yo I'm Server"
        }
    }
```

The following extensions can be used to pull data from a bound witness.  Party index 0 is the server, party 1 is the client.

**Payload parsing**

Given the above example of passing strings, you can resolve those strings for client/server using:

```swift
    if let resolveStr = withBoundWitness?.resolveString(forParty: 0) {
      dataStr += "Server: " + resolveStr
    }
    if let resolveStr1 = withBoundWitness?.resolveString(forParty: 1) {
      dataStr += " Client: " + resolveStr1
    }
```


Or you can get all heuristics in a dictionary for a given bound witness

```swift
 extension XyoBoundWitness {
    func allHeuristics() : [String:String] {
      return XyoHumanHeuristics.getAllHeuristics(self)
    }
 }
```


You can see individual heuristic resolvers in the source code: 

[GPS](./Heuristics/GpsResolver.swift)

[RSSI](./Heuristics/RssiResolver.swift)

[Time](./Heuristics/TimeResolver.swift)

The Human Heursitics Protocols can be found here

[HumanHeuristics](./Heuristics/XyoHumanHeuristics.swift)


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

Made with 🔥and ❄️ by [XYO](https://www.xyo.network)

