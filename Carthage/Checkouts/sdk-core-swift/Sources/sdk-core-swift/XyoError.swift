//
//  XyoError.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/22/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation

public enum XyoError : Error {
    case EXTREME_TESTING_ERROR // used for testing
    case MUST_BE_FETTER_OR_WITNESS // thrown when an item is added to a bound witness that is not a witness or a fetter
    case BW_IS_COMPLETED // thrown when a bound wittness is completed and you are trying to change it
    case BW_IS_IN_PROGRESS // throws when asked to do a bound witness but a bound witness in in progress
    case RESPONSE_IS_NULL
    case BYTE_ERROR
    case UNKNOWN_ERROR
}
