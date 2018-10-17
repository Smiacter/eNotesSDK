//
//  BlockchainBalance.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct BlockchainBalance: Decodable {
    var hash160: String
    var address: String
    var n_tx: Int
    var total_received: Int
    var total_sent: Int
    var final_balance: Int
}
