//
//  BlockchainUtxos.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//

struct BlockchainUtxosRaw: Decodable {
    var unspent_outputs: [BlockchainUtxos]
    
    func toUtxoModels() -> [UtxoModel] {
        var utxos = [UtxoModel]()
        for utxo in unspent_outputs {
            var utxoModel = UtxoModel()
            utxoModel.txid = utxo.tx_hash_big_endian
            utxoModel.index = UInt32(utxo.tx_output_n)
            utxoModel.script = utxo.script
            utxoModel.value = BTCAmount(utxo.value)
            utxoModel.confirmations = UInt(utxo.confirmations)
            utxos.append(utxoModel)
        }
        
        return utxos
    }
}

struct BlockchainUtxos: Decodable {
    var tx_hash: String
    var tx_hash_big_endian: String
    var tx_index: Int
    var tx_output_n: Int
    var script: String
    var value: Int
    var value_hex: String
    var confirmations: Int
}
