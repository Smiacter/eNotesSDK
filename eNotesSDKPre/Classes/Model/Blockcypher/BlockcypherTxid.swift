//
//  BlockcypherTxid.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/22.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct BlockcypherTxidRaw: Decodable {
    var tx: BlockcypherTxid
}

struct BlockcypherTxid: Decodable {
    var hash: String
}
