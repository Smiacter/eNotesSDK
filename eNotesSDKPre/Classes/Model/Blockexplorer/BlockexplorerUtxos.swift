//
//  BlockexplorerUtxos.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct BlockexplorerUtxos: Decodable {
    var address: String
    var txid: String
    var vout: Int
    var scriptPubKey: String
    var amount: Double
    var satoshis: Int
    var height: Int
    var confirmations: Int
    
    func toUtxoModel() -> UtxoModel {
        var utxoModel = UtxoModel()
        utxoModel.txid = txid
        utxoModel.index = UInt32(vout)
        utxoModel.script = scriptPubKey
        utxoModel.value = BTCAmount(satoshis)
        utxoModel.confirmations = UInt(confirmations)
        
        return utxoModel
    }
}
