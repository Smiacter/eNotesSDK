//
//  BlockexplorerFee.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct BlockexplorerFee: Decodable {
    var fee: Double
    
    enum CodingKeys: String, CodingKey {
        case fee = "3"
    }
}
