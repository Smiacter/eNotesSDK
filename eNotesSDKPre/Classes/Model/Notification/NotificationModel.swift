//
//  NotificationModel.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/24.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct NotificationModel: Decodable {
    var blockchain: String
    var net: String
    var cid: String
    var event: String
    var txid: String
}
