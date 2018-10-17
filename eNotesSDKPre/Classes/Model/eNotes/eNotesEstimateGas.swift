//
//  eNotesEstimateGas.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/16.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import UIKit

struct eNotesEstimateGasRaw: Decodable {
    var message: String
    var code: Int
    var data: eNotesEstimateGas
}

struct eNotesEstimateGas: Decodable {
    var gas: String
}
