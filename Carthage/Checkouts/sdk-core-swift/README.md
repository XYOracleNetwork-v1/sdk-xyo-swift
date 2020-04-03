[logo]: https://cdn.xy.company/img/brand/XYO_full_colored.png

[![logo]](https://xyo.network)

# sdk-core-swift

![](https://github.com/XYOracleNetwork/sdk-core-swift/workflows/Build/badge.svg)
[![](https://img.shields.io/cocoapods/v/sdk-core-swift.svg?style=flat)](https://cocoapods.org/pods/sdk-core-swift) [![Test Coverage](https://api.codeclimate.com/v1/badges/587ae96e86057b6b6178/test_coverage)](https://codeclimate.com/repos/5c4a7a7372b7b2029d008b34/test_coverage) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


## Table of Contents

-   [Title](#sdk-core-swift)
-   [Getting Started](#getting-started)
-   [Origin Chain](#origin-chain)
-   [Bound Witness](#bound-witness)
-   [Node Listener](#node-listener)
-   [TCP Node](#tcp-node)
-   [Maintainers](#maintainers)
-   [License](#license)
-   [Credits](#credits)

**NOTE** The latest version of this SDK includes the objectmodel as previously imported from `sdk-objectmodel-swift`.

This `README.md` document is an overview of the common methods that you may need when integrating the XYO Core SDK into your project. 

For an easy to use entry integration guide, take a look at our [Sample App Guide](/Sample/README.md)

A library to preform all core XYO Network functions.
This includes creating an origin chain, maintaining an origin chain, negotiations for talking to other nodes, and other basic functionality.
The library has heavily abstracted modules so that all operations will work with any crypto, storage, networking, ect.

The XYO protocol for creating origin-blocks is specified in the [XYO Yellow Paper](https://docs.xyo.network/XYO-Yellow-Paper.pdf). In it, it describes the behavior of how a node on the XYO network should create Bound Witnesses. Note, the behavior is not coupled with any particular technology constraints around transport layers, cryptographic algorithms, or hashing algorithms.

## Getting Started

### CocoaPods

> Note that current CocoaPods support is for iOS only

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.6.0.beta.2+ is required.

To integrate into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'sdk-core-swift', '0.1.6-beta.8'
end
```

Then, run the following command:

```bash
$ pod install
```

For a test run

```bash
pod try sdk-core-swift
```

## Origin Chain

The most common interface to this library through creating an origin chain creator object. Through an origin chain creator object one can create and maintain an origin chain. 

```swift
// this object will be used to hash items within the node
let hasher = XyoSha256()

// this is used as a key value store 
let storage = XyoInMemoryStorage()

// this is used as a place to store all of the bound witnesses/origin blocks
let chainRepo = XyoStorageOriginBlockRepository(storage: storage, hasher: hasher)

// this is used to save the state of the node (keys, index, previous hash)
let stateRepo = XyoStorageOriginStateRepository(storage: storage)

// this holds the state and the chain repository together
let configuration = XyoRepositoryConfiguration(originState: stateRepo, originBlock: chainRepo)

// the node to interface with creating an origin chain
let node = XyoOriginChainCreator(hasher: hasher, repositoryConfiguration: configuration)
```

After creating a node, it is standard to add a signer, and create a genesis block.

```swift
// creates a signer with a random private key
let signer = XyoSecp256k1Signer()
    
// adds the signer to the node
node.originState.addSigner(signer: signer)

// creates a origin block with its self (genesis block if this is the first block you make)
try node.selfSignOriginChain()
```

After creating a genesis block, your origin chain has officially started. Remember, all of the state is stored in the state repository (`XyoOriginChainStateRepository`) and the block repository (`XyoOriginBlockRepository`) that are constructed with the node. Both repositories are very high level and can be implemented for one's needs. Out of the box, this library comes with an implementation for key value store databases (`XyoStorageOriginBlockRepository`) and (`XyoStorageOriginChainStateRepository`). 

The `XyoStorageProvider` interface defines the methods for a simple key value store. There is a default implementation of an in memory key value store that comes with this library (`XyoInMemoryStorage`).

### Creating Origin Blocks

After a node has been created, it can be used to create origin blocks with other nodes. The process of talking to other nodes has been abstracted through use of a pipe (e.g. tcp, ble, memory) that handles all of the transport logic. This interface is defined as `XyoNetworkPipe`. This library ships with a memory pipe, and a tcp pipe.

**Using a tcp pipe** 

```swift
 // this defines who to create a tcp pipe with
let tcpPeer = XyoTcpPeer(ip: "myarchivist.com", port: 11000)

// prepares a socket tcp to communicate with the other node
let socket = XyoTcpSocket.create(peer: tcpPeer)

// wraps the socket to comply to the pipe interface
let pipe = XyoTcpSocketPipe(socket: socket, initiationData: nil)

// wraps the pipe to preform standard communications
let handler = XyoNetworkHandler(pipe: pipe)

node.boundWitness(handler: handler, procedureCatalogue: XyoProcedureCatalogue) { (boundWitness, error) in
    
}
```

**Using a memory pipe** 

```swift
let pipeOne = XyoMemoryPipe()
let pipeTwo = XyoMemoryPipe()

pipeOne.other = pipeTwo
pipeTwo.other = pipeOne

let handlerOne = XyoNetworkHandler(pipe: pipeOne)
let handlerTwo = XyoNetworkHandler(pipe: pipeTwo)

nodeOne.boundWitness(handler: handlerOne, procedureCatalogue: TestInteractionCatalogueCaseOne()) { (result, error) in
    // this should complete first
}

nodeTwo.boundWitness(handler: handlerTwo, procedureCatalogue: TestInteractionCatalogueCaseOne()) { (result, error) in
    // this should complete second
}
```

More example and bridge interactions can be found [here](https://github.com/XYOracleNetwork/sdk-core-swift/tree/docs/sdk-core-swiftTests/node/interaction)

**Bluetooth**

Bluetooth swift pipes for client and server can be found [here](https://github.com/XYOracleNetwork/sdk-xyobleinterface-swift).

**Other**

Other network pipes can be implemented as long as they follow the interface defined [here](https://github.com/XYOracleNetwork/sdk-core-swift/blob/docs/sdk-core-swift/network/XyoNetworkPipe.swift).

## Bound Witness

### Adding custom data to bound witnesses.

To add custom data to a bound witnesses, a XyoHeuristicGetter can be created:

```swift
public struct MyCustomData: XyoHeuristicGetter {
    public func getHeuristic() -> XyoObjectStructure? {
        if (conditionIsMet) {
            let myData = getDataSomehow()
            return myData
        }
        
        return nil
    }
}
```

After the getter has been created, it can be added to a node by calling:

```swift
 let myDataForBoundWitness = MyCustomData()
 node.addHeuristic (key: "MyData", getter : myDataForBoundWitness)
```

## Node Listener

### Adding a listener to a node

```swift
 struct MyListener : XyoNodeListener {
    /// This function will be called every time a bound witness has started
    func onBoundWitnessStart() {
        // update UI
    }
    
    /// This function is called when a bound witness starts, but fails due to an error
    func onBoundWitnessEndFailure() {
        // update UI
    }
    
    /// This function is called when the node discovers a new origin block, this is typicaly its new blocks
    /// that it is creating, but will be called when a bridge discovers new blocks.
    /// - Parameter boundWitness: The boundwitness just discovered
    func onBoundWitnessDiscovered(boundWitness : XyoBoundWitness) {
        // update UI
    }
    
    /// This function is called every time a bound witness starts and complets successfully.
    /// - Parameter boundWitness: The boundwitness just completed
    func onBoundWitnessEndSuccess(boundWitness : XyoBoundWitness) {
        // update UI
    }
}
```

You may add a listener to a node by adding the following:

```swift
  let listener = MyListener()
  myNode.addListener(key: "MyListener", listener : listener)
  
```

## TCP Node

### TCP Node Example

The following code is an example of a node that bound witnesses with a server 10 times.

```swift
let storage = XyoInMemoryStorage()
let blocks = XyoStrageProviderOriginBlockRepository(storageProvider: storage,
                                                    hasher: XyoSha256())
let state = XyoStorageOriginChainStateRepository(storage: storage)
let conf = XyoRepositoryConfiguration(originState: state, originBlock: blocks)
let node = XyoRelayNode(hasher: XyoSha256(),
                        repositoryConfiguration: conf,
                        queueRepository: XyoStorageBridgeQueueRepository(storage: storage))

node.originState.addSigner(signer: XyoSecp256k1Signer())

for i in 0..9 {
    let peer = XyoTcpPeer(ip: "alpha-peers.xyo.network", port: 11000)
    let socket = XyoTcpSocket.create(peer: peer)
    let pipe = XyoTcpSocketPipe(socket: socket, initiationData: nil)
    let handler = XyoNetworkHandler(pipe: pipe)

    let data = UInt32(XyoProcedureCatalogueFlags.TAKE_ORIGIN_CHAIN | XyoProcedureCatalogueFlags.GIVE_ORIGIN_CHAIN)
    node.boundWitness(handler: handler, procedureCatalogue: XyoFlagProcedureCatalogue(forOther: data, withOther: data)) { (result, error) in

    }
}
```

## Maintainers

- Carter Harrison
- Arie Trouw
- Kevin Weiler

## License

See the [LICENSE](LICENSE) file for license details.

## Credits 

Made with 🔥and ❄️ by [XYO](https://www.xyo.network)
