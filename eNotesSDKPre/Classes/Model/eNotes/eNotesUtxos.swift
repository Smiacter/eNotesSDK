//
//  eNotesUtxos.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 Smiacter. All rights reserved.
//
import ethers

struct eNotesUtxosRaw: Decodable {
    var code: Int
    var message: String
    var data: [eNotesUtxos]
    
    func toUtxoModels() -> [UtxoModel] {
        var utxos = [UtxoModel]()
        for utxo in filterUtxos() {
            var utxoModel = UtxoModel()
            utxoModel.txid = utxo.txid
            utxoModel.index = UInt32(BigNumber(hexString: utxo.index).integerValue)
            utxoModel.script = utxo.script
            utxoModel.value = BTCAmount(BigNumber(hexString: utxo.balance).integerValue)
            utxoModel.confirmations = 0 
            utxos.append(utxoModel)
        }
        
        return utxos
    }
    
    private func filterUtxos() -> [eNotesUtxos] {
        let positiveUtxos = data.filter{ return $0.positive == "true" }
        let negativeUtxos = data.filter{ return $0.positive != "true" }
        var utxos = data
        
        for neg in negativeUtxos {
            for pos in positiveUtxos {
                if neg.prevtxid == pos.txid, neg.index == pos.index {
                    utxos = utxos.filter{ $0 != neg }
                    utxos = utxos.filter{ $0 != pos }
                }
            }
        }
        
        return utxos
    }
}

struct eNotesUtxos: Decodable, Equatable {
    var address: String
    var txid: String
    var prevtxid: String?
    var index: String
    var script: String
    var height: String
    var balance: String
    var unit: String
    var comfirmed: String
    var positive: String
}
