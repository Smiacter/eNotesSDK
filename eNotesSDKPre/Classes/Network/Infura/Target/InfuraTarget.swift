//
//  InfuraTarget.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/13.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

struct InfuraTarget: SLTarget {
    var baseURLString: String {
        return "https://api.infura.io/v1/jsonrpc"
    }
    
    var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutForRequest
        return config
    }
}
