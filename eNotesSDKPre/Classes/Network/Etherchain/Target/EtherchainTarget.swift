//
//  EtherchainTarget.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/14.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

struct EtherchainTarget: SLTarget {
    var baseURLString: String {
        return "https://www.etherchain.org/api/gasPriceOracle"
    }
    
    var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutForRequest
        return config
    }
}
