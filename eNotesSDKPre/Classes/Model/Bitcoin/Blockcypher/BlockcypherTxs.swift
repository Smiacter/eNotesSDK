//
//  BlockcypherTxs.swift
//  eNotesSDKPre
//
//  Created by Smiacter on 2018/11/14.
//

struct BlockcypherTxsRaw: Decodable {
    var txrefs: [BlockcypherTxs]
}

struct BlockcypherTxs: Decodable {
    /// txid
    var tx_hash: String
    /// the unit is satoshi
    var value: Int64
    /// time: string type, format: "2018-11-14T02:14:47Z"
    var confirmed: String
    var confirmations: Int
    /// is sender
    var spent: Bool?
    
    /// string "2018-11-14T02:14:47Z" to TimeInterval
    func formatTime() -> TimeInterval {
        let tIndex = confirmed.positionOf(subStr: "T")
        let zIndex = confirmed.positionOf(subStr: "Z")
        let time1 = confirmed.subString(to: tIndex)
        let time2 = confirmed.subString(from: tIndex).subString(to: zIndex)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: "\(time1) \(time2)")
        return date?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    }
}
