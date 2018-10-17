//
//  InfuraTxReceipt.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/23.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct InfuraTxReceiptRaw: Decodable {
    var id: Int
    var jsonrpc: String
    var result: InfuraTxReceipt?
}

struct InfuraTxReceipt: Decodable {
    var status: String
}
