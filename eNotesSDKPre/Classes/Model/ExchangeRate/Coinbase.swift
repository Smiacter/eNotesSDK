//
//  Coinbase.swift
//  eNotes
//
//  Created by Smiacter on 2018/11/13.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct CoinbaseRaw: Decodable {
    var data: Coinbase
}

struct Coinbase: Decodable {
    var currency: String
    var rates: CoinbaseRates
}

struct CoinbaseRates: Decodable {
    var BTC: String
    var ETH: String
    var USD: String
    var CNY: String
    var EUR: String
    var JPY: String
}
