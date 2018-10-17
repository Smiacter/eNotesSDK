//
//  BitcoinfeesTarget.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

struct BitcoinfeesTarget: SLTarget {

    var baseURLString: String {
        return "https://bitcoinfees.earn.com/api/v1/fees/recommended"
    }
    
    var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutForRequest
        return config
    }
}
