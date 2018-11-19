//
//  Okex.swift
//  eNotes
//
//  Created by Smiacter on 2018/11/13.
//  Copyright © 2018 Smiacter. All rights reserved.
//

/// gusd to btc
struct OkexOther2Btc: Decodable {
    var instrument_id: String
    var last: String
}

/// btc or eth to usd
struct OkexOther2Usd: Decodable {
    var future_index: Double
}
