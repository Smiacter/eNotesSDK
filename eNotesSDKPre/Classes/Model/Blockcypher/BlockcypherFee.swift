//
//  BlockcypherFee.swift
//  eNotes
//
//  Created by Smiacter on 2018/9/4.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct BlockcypherFee: Decodable {
    var low_fee_per_kb: Int
    var medium_fee_per_kb: Int
    var high_fee_per_kb: Int
    
    func toBitcoinFee() -> BitcoinFees {
        return BitcoinFees(fastestFee: high_fee_per_kb, halfHourFee: medium_fee_per_kb, hourFee: low_fee_per_kb)
    }
}
