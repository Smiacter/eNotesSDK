//
//  BlockcypherBalance.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct BlockcypherBalance: Decodable {
    var address: String
    var total_received: Int
    var total_sent: Int
    var balance: Int
    var unconfirmed_balance: Int
    var final_balance: Int
    var n_tx: Int
    var unconfirmed_n_tx: Int
    var final_n_tx: Int
}
