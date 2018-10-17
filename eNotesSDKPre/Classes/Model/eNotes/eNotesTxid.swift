//
//  eNotesTxid.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/23.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct eNotesTxidRaw: Decodable {
    var code: Int
    var message: String
    var data: eNotesTxid
}

struct eNotesTxid: Decodable {
    var txid: String?
}
