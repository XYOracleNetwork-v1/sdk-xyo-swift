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

class XyoExampleViewController: UIViewController, BoundWitnessDelegate, UITableViewDelegate, UITableViewDataSource {
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
  

  
  @IBAction func changed(_ sender: UISwitch) {
    if isClient {
      bleNetwork?.client?.scan = sender.isOn
    } else {
      bleNetwork?.server?.listen = sender.isOn
    }
  }
  
  weak var bleNetwork : XyoBleNetwork?
  var xyoNode : XyoNode?
  

  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = isClient ? "Client" : "Server"
    scanLabel.text = isClient ? "Scan" : "Listen"
    let builder = XyoNodeBuilder()
    builder.setBoundWitnessDelegate(self)
    do {
      xyoNode = try builder.build()
      bleNetwork = xyoNode?.networks["ble"] as? XyoBleNetwork
      bleNetwork?.client?.scan = isClient
      bleNetwork?.server?.listen = !isClient
    }
    catch {
      print("Caught Error")
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
