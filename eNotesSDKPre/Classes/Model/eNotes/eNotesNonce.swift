//
//  eNotesNonce.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/15.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct eNotesNonceRaw: Decodable {
    var message: String
    var code: Int
    var data: eNotesNonce
}

struct eNotesNonce: Decodable {
    var nonce: String
}
