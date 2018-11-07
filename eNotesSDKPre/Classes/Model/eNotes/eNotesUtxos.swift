//
//  eNotesUtxos.swift
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
