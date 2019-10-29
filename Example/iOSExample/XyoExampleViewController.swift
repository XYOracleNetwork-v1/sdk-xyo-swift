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

class XyoExampleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  public var isClient: Bool = true
  public var isLockedOnBottom: Bool = true
  
  var isScrolling = false

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

  @IBOutlet weak var scanLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  var boundWitnesses : [BoundWitnessResult] = []
  
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
    if let debug = boundWitnesses[indexPath.item].debugString {
      if detail.count > 0 {
        detail.append(" - ")
      }
      detail.append(debug)
    }
    cell.detailTextLabel?.text = detail;
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
    
    let resolveStr = withBoundWitness?.resolvePayloadData()
    boundWitnesses.append(BoundWitnessResult(device: withDeviceId, dataString: resolveStr, debugString: withBoundWitness.debugDescription))
    tableView.reloadData()
    
    // Scroll to bottom
    if (isLockedOnBottom && !isScrolling) {
      DispatchQueue.main.async {
        self.tableView.scrollToRow(at: IndexPath(item: self.boundWitnesses.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
      }
    }

  }
  
  func boundWitness(failed withDeviceId: String?, withError: XyoError) {
    print("Errored BW with \(String(describing: withDeviceId))")
  }
  
  func getPayloadData() -> [UInt8]? {
    if isClient {
//      let data = ("Is Client".cString(using: .utf8))
      let data = [UInt8]("Is Client".utf8)
      return data
    }
    return nil
  }
}



extension XyoBoundWitness {
  // TODO Blob Resolver
  func resolvePayloadData() -> String {
    let resolver = TimeResolver()
    XyoHumanHeuristics.resolvers[XyoSchemas.UNIX_TIME.id] = resolver
    let key = resolver.getHumanKey(partyIndex: 1)
    return XyoHumanHeuristics.getHumanHeuristics(boundWitness: self).index(forKey: key).debugDescription
  }
}
