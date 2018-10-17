//
//  eNotesBalance.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/23.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct eNotesBalanceRaw: Decodable {
    var code: Int
    var message: String
    var data: eNotesBalance
}

struct eNotesBalance: Decodable {
    var balance: String?
}
