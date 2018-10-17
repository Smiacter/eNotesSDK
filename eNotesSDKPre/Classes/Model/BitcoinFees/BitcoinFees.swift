//
//  BitcoinFees.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//

public struct BitcoinFees: Decodable {
    var fastestFee: Int
    var halfHourFee: Int
    var hourFee: Int
}
