//
//  BlockexplorerTarget.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

struct BlockexplorerTarget: SLTarget {

    var baseURLString: String {
        return "https://"
    }
    
    var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutForRequest
        return config
    }
}
