//
//  XyoExampleViewController.swift
//  iOSExample
//
//  Created by Kevin Weiler on 10/17/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import sdk_xyo_swift
import sdk_core_swift

struct BoundWitnessResult {
  var device: String;
  var dataString: String;
}

class XyoExampleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  public var isClient: Bool = true
  
  @IBOutlet weak var scanLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  var boundWitnesses : [BoundWitnessResult] = []
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return boundWitnesses.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BoundWitnessCelId", for: indexPath)
    cell.textLabel?.text = boundWitnesses[indexPath.item].device;
    cell.detailTextLabel?.text = boundWitnesses[indexPath.item].dataString;
    return cell;
  }
  
  @IBAction func autoBridgeToggled(_ sender: UISwitch) {
    updateBridging(on: sender.isOn)
  }
  
  
  @IBAction func scanListenToggled(_ sender: UISwitch) {
    updateScanning(on: sender.isOn)
  }
  
  func updateScanning(on: Bool) {
    let ble = xyoNode?.networks["ble"] as? XyoBleNetwork

    if isClient {
      ble?.client?.scan = on
    } else {
      ble?.server?.listen = on
    }
  }
  
  func updateBridging(on: Bool) {
    let tcp = xyoNode?.networks["tcpip"] as? XyoTcpipNetwork

    if isClient {
      tcp?.client?.autoBridge = on
    } else {
      tcp?.server?.autoBridge = on
    }
  }
  
  // Strong ref to xyonode here  
  var xyoNode : XyoNode?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = isClient ? "Client" : "Server"
    scanLabel.text = isClient ? "Scan" : "Listen"
    let builder = XyoNodeBuilder()
    builder.setBoundWitnessDelegate(self)
    do {
      xyoNode = try builder.build()
      updateScanning(on: true)
      updateBridging(on: false)
    }
    catch {
      print("Caught Error \(error)")
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    print("Xyo VC going away, remove retain cycle")
    XyoSdk.nodes.removeAll()
    xyoNode = nil
  }
  
  deinit {
    print("XyoExampleViewController deinit")
  }
}

extension XyoExampleViewController : BoundWitnessDelegate {
  func boundWitness(started withDeviceId: String) {
    print("Started BW with \(withDeviceId)")
  }
  
  func boundWitness(completed withDeviceId: String, withBoundWitness: XyoBoundWitness?) {
    print("Completed BW with \(withDeviceId)")
    boundWitnesses.append(BoundWitnessResult(device: withDeviceId, dataString: withBoundWitness.debugDescription))
    tableView.reloadData()
  }
  
  func boundWitness(failed withDeviceId: String?, withError: XyoError) {
    print("Errored BW with \(String(describing: withDeviceId))")
  }
  
  func getPayloadData() -> [UInt8]? {
    let test = "Test"
    return [UInt8](test.utf8)
  }
}
