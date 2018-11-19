//
//  CryptoCompareTarget.swift
//  eNotes
//
//  Created by Smiacter on 2018/10/16.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

struct CryptoCompareTarget: SLTarget {
    var baseURLString: String {
        return "https://min-api.cryptocompare.com/data/pricemulti?"
    }
    
    var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutForRequest
        return config
    }
}
