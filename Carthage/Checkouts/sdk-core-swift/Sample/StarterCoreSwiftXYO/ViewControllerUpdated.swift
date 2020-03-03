//
//  ViewController.swift
//  StarterCoreSwiftXYO
//
//  Updated by Phillip Lorenzo on 9/05/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import UIKit
import CoreLocation
import sdk_core_swift

class ViewController: UIViewController {
    private let locationManager = CLLocationManager()
    private let hasher = XyoSha256()
    private let store = XyoInMemoryStorage()
    private lazy var state = XyoStorageOriginStateRepository(storage: store)
    private lazy var blocks = XyoStorageProviderOriginBlockRepository(storageProvider: store, hasher: hasher)
    private lazy var conf = XyoRepositoryConfiguration(originState: state, originBlock: blocks)
    private lazy var node = XyoOriginChainCreator(hasher: hasher, repositoryConfiguration: conf)
    
    private lazy var doBoundWitnessButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        
        button.setTitle("Create Origin", for: UIControl.State.normal)
        
        return button
    }()
    
    private lazy var heuristicViewButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        
        button.setTitle("View Additional Heuristics", for: UIControl.State.normal)
        
        return button
    }()

    private lazy var doBoundWitness: UILabel = {
        let text = UILabel()
        
        text.textColor = UIColor.black
        
        text.font = UIFont.systemFont(ofSize: 20, weight: .black)
        
        text.numberOfLines = 0
        
        return text
    }()

    private lazy var doLocation: UILabel = {
        let text = UILabel()
        
        text.textColor = UIColor.red
        
        text.font = UIFont.systemFont(ofSize: 13, weight: .black)
        
        return text
    }()
    
    private lazy var appTitle: UILabel = {
        let text = UILabel()
        
        text.textColor = UIColor.purple
        
        text.font = UIFont.systemFont(ofSize: 20, weight: .black)
        
        text.numberOfLines = 0
        
        return text
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        node.addListener(key: "main", listener: self)
        node.addHeuristic(key: "gps", getter: self)
        locationManager.startUpdatingLocation()
        layoutButton()
        heuristicButton()
        layout()
    }
    
    private func layout () {
        appTitle.text = "Sample XYO App"
        
        view.addSubview(appTitle)
        view.addSubview(doBoundWitness)
        view.addSubview(doLocation)
        
        appTitle.translatesAutoresizingMaskIntoConstraints = false
        appTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        appTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        doBoundWitness.translatesAutoresizingMaskIntoConstraints = false
        
        doLocation.translatesAutoresizingMaskIntoConstraints = false
        
        doBoundWitness.bottomAnchor.constraint(equalTo: doBoundWitnessButton.topAnchor, constant: -80).isActive = true
        doBoundWitness.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        doBoundWitness.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80).isActive = true
        
        doLocation.bottomAnchor.constraint(equalTo: doBoundWitnessButton.topAnchor, constant: 100).isActive = true
        doLocation.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    }
    
    private func layoutButton () {
        view.addSubview(doBoundWitnessButton)
        doBoundWitnessButton.translatesAutoresizingMaskIntoConstraints = false
        doBoundWitnessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        doBoundWitnessButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        let click = UITapGestureRecognizer(target: self, action: #selector(onButtonClick(_:)))
        doBoundWitnessButton.addGestureRecognizer(click)
    }
    
    private func heuristicButton () {
        view.addSubview(heuristicViewButton)
        heuristicViewButton.translatesAutoresizingMaskIntoConstraints = false
        heuristicViewButton.centerYAnchor.constraint(equalTo: doBoundWitnessButton.bottomAnchor,
          constant: 200).isActive = true
        heuristicViewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let click = UITapGestureRecognizer(target: self, action: #selector(addHeuristicView(_:)))
        heuristicViewButton.addGestureRecognizer(click)
    }
    
    @objc func onButtonClick (_ sender: UITapGestureRecognizer) {
        print("doing bound witness")
        try? node.selfSignOriginChain()
    }
    
    @objc func addHeuristicView (_ sender: UITapGestureRecognizer) {
        print("add heuristic")
    }
}

extension ViewController : XyoNodeListener {
    // not needed
    func onBoundWitnessStart() {}
    func onBoundWitnessEndFailure() {}
    func onBoundWitnessDiscovered(boundWitness: XyoBoundWitness) {}

    func onBoundWitnessEndSuccess(boundWitness: XyoBoundWitness) {
        let hash = (try? boundWitness.getHash(hasher: hasher))?.getBuffer().toByteArray().toHexString()
        doBoundWitness.text = hash
    }
}

extension ViewController : XyoHeuristicGetter {
    func getHeuristic() -> XyoObjectStructure? {
        guard let lat: Double = locationManager.location?.coordinate.latitude else {
            return nil
        }
        
        guard let lng: Double = locationManager.location?.coordinate.longitude else {
            return nil
        }
        
        doLocation.text = "\(lat), \(lng)"
        
        let encodedLat = XyoObjectStructure.newInstance(schema: XyoSchemas.LAT, bytes: XyoBuffer(data: anyToBytes(lat)))
        let encodedLng = XyoObjectStructure.newInstance(schema: XyoSchemas.LNG, bytes: XyoBuffer(data: anyToBytes(lng)))
        return XyoIterableStructure.createUntypedIterableObject(schema: XyoSchemas.GPS, values: [encodedLat, encodedLng])
        
        
    }
    
    func anyToBytes<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafeBytes(of: &value) { Array($0) }.reversed()
    }
}
