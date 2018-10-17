//
//  eNotesEstimateFee.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct eNotesEstimateFeeRaw: Decodable {
    var code: Int
    var message: String
    var data: eNotesEstimateFee
}

struct eNotesEstimateFee: Decodable {
    var feerate: String
    var blocks: String
}
