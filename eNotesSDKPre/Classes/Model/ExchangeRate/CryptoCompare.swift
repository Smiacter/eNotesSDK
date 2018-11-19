//
//  CryptoCompare.swift
//  eNotes
//
//  Created by Smiacter on 2018/10/16.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct CryptoCompare: Decodable {
    var ETH: CryptoCompareRates?
    var BTC: CryptoCompareRates?
    var GUSD: CryptoCompareRates?
}

struct CryptoCompareRates: Decodable {
    let BTC: Double?
    let ETH: Double?
    let GUSD: Double?
    let USD: Double?
    let CNY: Double?
    let EUR: Double?
    let JPY: Double?
}
