//
//  BlockexplorerTxs.swift
//  eNotesSDKPre
//
//  Created by Smiacter on 2018/11/14.
//

struct BlockexplorerTxsRaw: Decodable {
    var to: Int?
    var items: [BlockexplorerTxs]
}

struct BlockexplorerTxs: Decodable {
    var txid: String
    var time: TimeInterval
    /// unit is BTC
    var valueIn: Double
    var valueOut: Double
    var confirmations: Int
    var vin: [BlockexplorerTxsInputs]
}

struct BlockexplorerTxsInputs: Decodable {
    var addr: String
}


