//
//  BlockcypherTarget.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

struct BlockcypherTarget: SLTarget {
    
    var baseURLString: String {
        return "https://api.blockcypher.com/v1/btc"
    }
    
    var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutForRequest
        return config
    }
}
