//
//  Bitz.swift
//  eNotes
//
//  Created by Smiacter on 2018/11/13.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct BitzRaw: Decodable {
    var msg: String
    var data: Bitz
}

struct Bitz: Decodable {
    var btc: BitzRates?
    var eth: BitzRates?
}

struct BitzRates: Decodable {
    var btc: String
    var eth: String
    var usd: String
    var cny: String
    var eur: String
    var jpy: String
}
