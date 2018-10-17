//
//  eNotesTxReceipt.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/23.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct eNotesTxReceiptRaw: Decodable {
    var code: Int
    var message: String
    var data: eNotesTxReceipt
}

struct eNotesTxReceipt: Decodable {
    var confirmations: String?
}
