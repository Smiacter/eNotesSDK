//
//  BlockcypherUtxos.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/20.
//  Copyright © 2018 eNotes. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

struct BlockcypherUtxosRaw: Decodable {
    /// confirmed
    var txrefs: [BlockcypherUtxosConfirmed]?
    /// unconfirmed
    var unconfirmed_txrefs: [BlockcypherUtxosUnConfirmed]?
    
    func toUtxoModels() -> [UtxoModel] {
        guard txrefs != nil else { return [] }
        var utxos = [UtxoModel]()
        for utxo in txrefs! {
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
