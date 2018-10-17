//
//  eNotesGasPrice.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/14.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct eNotesGasPriceRaw: Decodable {
    var message: String
    var code: Int
    var data: eNoteGasPrice
    
//    enum CodingKeys: String, CodingKey {
//        case message, code
//        case gasPrice = "data"
//    }
}

struct eNoteGasPrice: Decodable {
    var price: String
    var unit: String
}
