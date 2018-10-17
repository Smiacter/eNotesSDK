//
//  eNotesCall.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/15.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct eNotesCallRaw: Decodable {
    var message: String
    var code: Int
    var data: eNotesCall
}

struct eNotesCall: Decodable {
    var result: String
}
