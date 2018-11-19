//
//  OkexTarget.swift
//  eNotes
//
//  Created by Smiacter on 2018/11/13.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

struct OkexTarget: SLTarget {

    var baseURLString: String {
        return "https://www.okex.com/api"
    }
    
    var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutForRequest
        return config
    }
}
