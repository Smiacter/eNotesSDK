//
//  BitzTarget.swift
//  eNotes
//
//  Created by Smiacter on 2018/11/13.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

struct BitzTarget: SLTarget {

    var baseURLString: String {
        return "https://apiv2.bitz.com/Market/currencyCoinRate?coins="
    }
    
    var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutForRequest
        return config
    }
}
