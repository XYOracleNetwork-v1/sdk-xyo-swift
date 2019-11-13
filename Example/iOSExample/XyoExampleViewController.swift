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
  var device: String
  var dataString: String?
  var debugString: String?
}

class XyoExampleViewController: UIViewController {
  @IBOutlet weak var scanLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  public var isClient: Bool = true
  
  var isLockedOnBottom: Bool = true
  var isScrolling = false
  var boundWitnesses : [BoundWitnessResult] = []
  var xyoNode : XyoNode?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = isClient ? "Client" : "Server"
    scanLabel.text = isClient ? "Scan" : "Listen"
    
    let builder = XyoNodeBuilder()
    builder.setBoundWitnessDelegate(self)
    do {
      xyoNode = try builder.build()
    }
    catch {
      print("Caught Error Building Xyo Node\(error)")
    }
    if var bleClient = (xyoNode?.networks["ble"] as? XyoBleNetwork)?.client {
      bleClient.pollingInterval = 10
      bleClient.stringHeuristic = "Hi I'm Client"
    }
    
    if var bleServer = (xyoNode?.networks["ble"] as? XyoBleNetwork)?.server {
      bleServer.stringHeuristic = "Yo I'm Server"
    }
    // Start client/server scanning and listening
    setupNodeScanningListening(on: true)
    updateBridging(on: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    print("Xyo VC going away, remove retain cycle")
    XyoSdk.nodes.removeAll()
    xyoNode = nil
  }
  
  deinit {
    print("XyoExampleViewController deinit")
  }

  @IBAction func autoBridgeToggled(_ sender: UISwitch) {
    updateBridging(on: sender.isOn)
  }
  
  
  @IBAction func scanListenToggled(_ sender: UISwitch) {
    setupNodeScanningListening(on: sender.isOn)
  }
  
  
  
  func setupNodeScanningListening(on: Bool) {
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
    
  
}

extension XyoExampleViewController : UITableViewDelegate, UITableViewDataSource {
  
  /// Table view datasource/delegate
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return boundWitnesses.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BoundWitnessCelId", for: indexPath)
    cell.textLabel?.text = boundWitnesses[indexPath.item].device;
    var detail = ""
    if let data = boundWitnesses[indexPath.item].dataString {
      detail.append(data)
    }
    
    cell.detailTextLabel?.text = detail;
    return cell;
  }
  
  /// Scroll view delegation
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      isScrolling = true
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
      if !decelerate { scrollViewDidEndScrolling(scrollView) }
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      scrollViewDidEndScrolling(scrollView)
  }

  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
      scrollViewDidEndScrolling(scrollView)
  }

  func scrollViewDidEndScrolling(_ scrollView: UIScrollView) {
      isScrolling = false
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let scrollViewHeight = scrollView.frame.size.height
    let scrollContentSizeHeight = scrollView.contentSize.height
    let scrollOffset = scrollView.contentOffset.y
    if (scrollOffset + scrollViewHeight + 100 >= scrollContentSizeHeight)
    {
        isLockedOnBottom = true
    } else {
      isLockedOnBottom = false
    }
  }
}

extension XyoExampleViewController : BoundWitnessDelegate {
  func boundWitness(started withDeviceId: String) {
    print("Started BW with \(withDeviceId)")
  }
  
  func boundWitness(completed withDeviceId: String, withBoundWitness: XyoBoundWitness?) {
    print("Completed BW with \(withDeviceId)")
    
    var dataStr = ""

    if let resolveStr = withBoundWitness?.resolveString(forParty: 0) {
      dataStr += "Server: " + resolveStr
    }
    if let resolveStr1 = withBoundWitness?.resolveString(forParty: 1) {
      dataStr += " Client: " + resolveStr1
    }
    if let rssistr = withBoundWitness?.resolveRssiPayload(forParty: 1) {
      dataStr += " Rssi: " + rssistr
    }
    boundWitnesses.append(BoundWitnessResult(device: withDeviceId, dataString: dataStr, debugString: withBoundWitness.debugDescription))
    tableView.reloadData()
    
    // Scroll to bottom
    if (isLockedOnBottom && !isScrolling) {
      DispatchQueue.main.async {
        self.tableView.scrollToRow(at: IndexPath(item: self.boundWitnesses.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
      }
    }

  }
  
  func boundWitness(failed withDeviceId: String?, withError: XyoError) {
    print("Errored BW with \(String(describing: withDeviceId)) \(String(describing: withError))")
  }
  
}




