//
//  eNotesNetworkManager.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/23.
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

import UIKit
import Alamofire

class eNotesNetworkManager: NSObject {
    static let shared = eNotesNetworkManager()
    private override init() {
        
    }
}

// MARK: Universal

extension eNotesNetworkManager {
    
    func getBalance(blockchain: Blockchain, network: Network, address: String, closure: balanceClosure) {
        
        let request = eNotesArrayPostRequest()
        request.path = "/get_address_balance"
        request.anyKey = [["blockchain": blockchain.eNotesString, "network": network.eNotesString, "address": address]]
        eNotesNetwork.request(request) { (response) in
            let error = response.error
            if let model = response.decode(to: [eNotesBalanceRaw].self) {
                closure?(model.toBalance(), response.error)
            } else {
                closure?("", error ?? response.error)
            }
        }
    }
    
    func sendTransaction(blockchain: Blockchain, network: Network, rawtx: String, closure: txIdClosure) {
        
        let request = eNotesArrayPostRequest()
        request.path = "/send_raw_transaction"
        request.anyKey = [["blockchain": blockchain.eNotesString, "network": network.eNotesString, "rawtx": rawtx]]
        eNotesNetwork.request(request) { (response) in
            let error = response.error
            if let model = response.decode(to: [eNotesTxidRaw].self), !model.toTxId().isEmpty {
                closure?(model.toTxId(), response.error)
            } else {
                closure?("", error ?? response.error)
            }
        }
    }
    
    func getTxReceipt(blockchain: Blockchain, network: Network, txid: String, closure: txReceiptClosure) {
        
        let request = eNotesArrayPostRequest()
        request.path = "/get_transaction_receipt"
        request.anyKey = [["blockchain": blockchain.eNotesString, "network": network.eNotesString, "txid": txid]]
        eNotesNetwork.request(request) { (response) in
            let error = response.error
            if let model = response.decode(to: [[eNotesTxReceiptRaw]].self) {
                closure?(model.toConfirmStatus(), response.error)
            } else {
                closure?(.none, error ?? response.error)
            }
        }
    }
    
    /// subscribe Notification
    /// clientId: Getui Client id
    func subscribeNotification(blockchain: Blockchain, clientId: String, network: Network, txid: String) {
        
        let request = eNotesArrayPostRequest()
        request.path = "/subscribe_notification"
        request.anyKey = [["blockchain": blockchain.eNotesString, "network": network.eNotesString, "txid": txid, "event": "txreceipt", "cid": clientId]]
        eNotesNetwork.request(request) { (response) in
            
        }
    }
}

// MARK: Btc

extension eNotesNetworkManager {
    
    func getUtxos(network: Network, address: String, closure: btcUtxosClosure) {
        let request = eNotesUtxosRequest()
        request.path = "/get_address_utxos/bitcoin/\(network.network(api: .eNotes))/?address=\(address)"
        eNotesNetwork.request(request) { (response) in
            let error = response.error
            if let model = response.decode(to: eNotesUtxosRaw.self) {
                closure?(model.toUtxos(), response.error)
            } else {
                closure?([], error ?? response.error)
            }
        }
    }
    
    func getTxFee(api: ApiType, network: Network, closure: btcTxFeeClosure) {
        let request = eNotesEstimateFeeRequest()
        request.path = "/estimate_fee/bitcoin/\(network.network(api: api))/?blocks=1"
        eNotesNetwork.request(request) { (response) in
            let error = response.error
            if let model = response.decode(to: eNotesEstimateFeeRaw.self) {
                closure?(model.toBtcTxFee(), nil, response.error)
            } else {
                closure?(0, nil, error ?? response.error)
            }
        }
    }
}

// MARK: Eth

extension eNotesNetworkManager {
    
    func getGasPrice(api: ApiType, network: Network, closure: ethGasPriceClosure) {
        let request = eNotesGasPriceRequest()
        request.path = "/get_gas_price/ethereum/\(network.network(api: api))"
        eNotesNetwork.request(request) { (response) in
            let error = response.error
            if let model = response.decode(to: eNotesGasPriceRaw.self) {
                closure?(model.toGasPrice(), nil, response.error)
            } else {
                closure?("", nil, error ?? response.error)
            }
        }
    }
    
    func call(api: ApiType, network: Network, toAddress: String, dataStr: String, closure: ethCallClosure) {
        let request = eNotesCallRequest()
        request.path = "/eth_call/ethereum/\(network.network(api: api))/?to=\(toAddress)&data=\(dataStr.addHexPrefix())"
        eNotesNetwork.request(request) { (response) in
            let error = response.error
            if let model = response.decode(to: eNotesCallRaw.self) {
                closure?(model.data.result, response.error)
            } else {
                closure?("", error ?? response.error)
            }
        }
    }
    
    func getNonce(api: ApiType, network: Network, address: String, closure: ethNonceClosure) {
        let request = eNotesNonceRequest()
        request.path = "/get_address_nonce/ethereum/\(network.network(api: api))/?address=\(address)"
        eNotesNetwork.request(request) { (response) in
            let error = response.error
            if let model = response.decode(to: eNotesNonceRaw.self) {
                closure?(model.toNonce(), response.error)
            } else {
                closure?(0, error ?? response.error)
            }
        }
    }
    
    func getEstimateGas(api: ApiType, network: Network, from: String, to address: String, value: String, data: String? = nil, closure: ethEstimateGasClosure) {
        let dataStr = data != nil ? "&data=\(data!)" : ""
        let request = eNotesEstimateGasRequest()
        request.path = "/estimate_gas/ethereum/\(network.network(api: api))/?from=\(from)&to=\(address)&value=\(value)\(dataStr)"
        eNotesNetwork.request(request) { (response) in
            let error = response.error
            if let model = response.decode(to: eNotesEstimateGasRaw.self) {
                closure?(model.toEstimateGas(), response.error)
            } else {
                closure?("", error ?? response.error)
            }
        }
    }
}

