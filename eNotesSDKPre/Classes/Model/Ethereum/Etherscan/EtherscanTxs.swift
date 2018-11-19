//
//  EtherscanTxs.swift
//  eNotesSDKPre
//
//  Created by Smiacter on 2018/11/15.
//

struct EtherscanTxsRaw: Decodable {
    var result: [EtherscanTxs]
}

struct EtherscanTxs: Decodable {
    var timeStamp: String
    var hash: String
    /// smallest unit
    var value: String
    var confirmations: String
    /// send address
    var from: String
}
