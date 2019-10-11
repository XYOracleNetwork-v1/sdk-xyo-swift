//
//  BoundWitness.swift
//  sdk-xyo-swift
//
//  Created by Kevin Weiler on 10/10/19.
//

import Foundation
import sdk_core_swift


class BoundWitness: BoundWitnessParseable {

    
    var boundWitness: XyoBoundWitness
    
    var options: ParseOptions
    
    required init(_boundWitness: XyoBoundWitness, _options: ParseOptions?) {
        boundWitness = _boundWitness
        options = _options ?? ParseOptions()
    }
    
    func heuristic<ExpectedHeuristic>(forKey: String) -> ExpectedHeuristic {
        <#code#>
    }
    
    func address(index: Int) -> String {
        <#code#>
    }
    
    func signature(index: Int) -> String {
        <#code#>
    }
    
    func allAddresses() -> [String] {
        <#code#>
    }
    
    func allSignatures(format: String) -> [String] {
        <#code#>
    }
    
    func asJson() -> [String : Any] {
        <#code#>
    }
    
    func bytes() -> Data {
        <#code#>
    }
    
    func hash() -> String {
        <#code#>
    }
    
    
}
