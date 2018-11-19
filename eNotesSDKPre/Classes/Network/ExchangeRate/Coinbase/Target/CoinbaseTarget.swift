//
//  CoinbaseTarget.swift
//  eNotes
//
//  Created by Smiacter on 2018/11/13.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

struct CoinbaseTarget: SLTarget {
    
    var baseURLString: String {
        return "https://api.coinbase.com/v2/exchange-rates?currency="
    }
    
    var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutForRequest
        return config
    }
}
