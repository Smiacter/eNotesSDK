//
//  BlockcypherUtxos.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct BlockcypherUtxosRaw: Decodable {
    /// confirmed
    var txrefs: [BlockcypherUtxosConfirmed]
    /// unconfirmed
//    var unconfirmed_txrefs: [BlockcypherUtxosUnConfirmed]
    
    func toUtxoModels() -> [UtxoModel] {
        var utxos = [UtxoModel]()
        for utxo in txrefs {
            var utxoModel = UtxoModel()
            utxoModel.txid = utxo.tx_hash
            utxoModel.index = UInt32(utxo.tx_output_n)
            utxoModel.script = utxo.script
            utxoModel.value = BTCAmount(utxo.value)
            utxoModel.confirmations = UInt(utxo.confirmations)
            utxos.append(utxoModel)
        }
        
        return utxos
    }
}

struct BlockcypherUtxosConfirmed: Decodable {
    var tx_hash: String
    var block_height: Int
    var tx_input_n: Int
    var tx_output_n: Int
    var value: Int
    var ref_balance: Int
    var spent: Bool
    var confirmations: Int
    var confirmed: String
    var double_spend: Bool
    var script: String
}

struct BlockcypherUtxosUnConfirmed: Decodable {
    var tx_hash: String
    var block_height: Int
    var tx_input_n: Int
    var tx_output_n: Int
    var value: Int
    var ref_balance: Int
    var spent: Bool
    var confirmations: Int
    var confirmed: String
    var double_spend: Bool
    var script: String
}
