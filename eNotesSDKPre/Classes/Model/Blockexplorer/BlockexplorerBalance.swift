//
//  BlockexplorerBalance.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct BlockexplorerBalance: Decodable {
    var addrStr: String
    /// satoshi balance, we need this
    var balanceSat: Int
}
