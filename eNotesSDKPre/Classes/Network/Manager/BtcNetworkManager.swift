//
//  BtcNetworkManager.swift
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

class BtcNetworkManager: NSObject {
    static let shared = BtcNetworkManager()
    private override init() {
        
    }
}

// MARK: Btc

extension BtcNetworkManager {
    
    func getBalance(apis: [ApiType] = BtcCommonApis, error: NSError? = nil, blockchain: Blockchain, network: Network, address: String, closure: balanceClosure) {
        guard apis.count > 0 else { closure?("", error); return }
        
        let api = apis[0]
        let leftApis = apis.filter{ $0 != api }
        switch api {
        case .blockchain:
            let request = BlockchainBalanceRequest()
            request.path = "\(network.network(api: api))blockchain.info/rawaddr/\(address)?limit=0&filter=5"
            BlockchainNetwork.request(request) { (response) in
                let error = response.error // decode will change response.error, so define a temp var here
                if let model = response.decode(to: BlockchainBalance.self) {
                    closure?(model.toBalance(), response.error)
                } else {
                    self.getBalance(apis: leftApis, error: error ?? response.error, blockchain: blockchain, network: network, address: address, closure: closure)
                }
            }
        case .blockcypher:
            let request = BlockcypherBalanceRequest()
            request.path = "/\(network.network(api: api))/addrs/\(address)/balance?token=\(BlockcypherApiKeys.random())"
            BlockcypherNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BlockcypherBalance.self) {
                    closure?(model.toBalance(), response.error)
                } else {
                    self.getBalance(apis: leftApis, error: error ?? response.error, blockchain: blockchain, network: network, address: address, closure: closure)
                }
            }
        case .blockexplorer:
            let request = BlockexplorerBalanceRequest()
            request.path = "\(network.network(api: api))blockexplorer.com/api/addr/\(address)"
            BlockexplorerNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BlockexplorerBalance.self) {
                    closure?(model.toBalance(), response.error)
                } else {
                    self.getBalance(apis: leftApis, error: error ?? response.error, blockchain: blockchain, network: network, address: address, closure: closure)
                }
            }
        case .eNotes:
            eNotesNetworkManager.shared.getBalance(blockchain: blockchain, network: network, address: address, closure: closure)
        default:
            break
        }
    }
    func getMultBalances(network: Network, addresses: [String], closure: multBalanceClosure) {
        let addressStr = EnoteFormatter.packingArrToString(arr: addresses, seperator: "|")
        let request = BlockchainBalanceRequest()
        request.path = "\(network.network(api: .blockchain))blockchain.info/multiaddr?active=\(addressStr)&n=1&limit=0&filter=5".urlEncoded()
        BlockchainNetwork.request(request) { (response) in
            guard response.error == nil else { closure?(nil, response.error); return }
            guard let model = response.decode(to: BlockchainMultBalanceRaw.self) else { closure?(nil, response.error); return }
            closure?(model.toMultBalance(), response.error)
        }
    }
    
    func getUtxos(apis: [ApiType] = BtcCommonApis, error: NSError? = nil, network: Network, address: String, closure: btcUtxosClosure) {
        guard apis.count > 0 else { closure?([], error); return }
        
        let api = apis[0]
        let leftApis = apis.filter{ $0 != api }
        switch api {
        case .blockchain:
            let request = BlockchainUtxosRequest()
            request.path = "\(network.network(api: api))blockchain.info/unspent?active=\(address)"
            BlockchainNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BlockchainUtxosRaw.self) {
                    closure?(model.toUtxos(), response.error)
                } else {
                    self.getUtxos(apis: leftApis, error: error ?? response.error, network: network, address: address, closure: closure)
                }
            }
        case .blockcypher:
            let request = BlockcypherUtxosRequest()
            request.path = "/\(network.network(api: api))/addrs/\(address)?token=\(BlockcypherApiKeys.random())&unspentOnly=true&includeScript=true"
            BlockcypherNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BlockcypherUtxosRaw.self) {
                    closure?(model.toUtxos(), response.error)
                } else {
                    self.getUtxos(apis: leftApis, error: error ?? response.error, network: network, address: address, closure: closure)
                }
            }
        case .blockexplorer:
            let request = BlockexplorerUtxosRequest()
            request.path = "\(network.network(api: api))blockexplorer.com/api/addr/\(address)/utxo"
            BlockexplorerNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: [BlockexplorerUtxos].self) {
                    closure?(model.toUtxos(), response.error)
                } else {
                    self.getUtxos(apis: leftApis, error: error ?? response.error, network: network, address: address, closure: closure)
                }
            }
        case .eNotes:
            eNotesNetworkManager.shared.getUtxos(network: network, address: address, closure: closure)
        default:
            break
        }
    }
    
    func getEstimateFee(network: Network, closure: btcTxFeeClosure) {
        getTxFee(apiOrders: network == .mainnet ? DefaultBtcFeeApiOrder : DefaultBtcFeeTestApiOrder, network: network, closure: closure)
    }
    
    private func getTxFee(apiOrders: [ApiType] = DefaultBtcFeeApiOrder, error: NSError? = nil, network: Network, closure: btcTxFeeClosure) {
        guard apiOrders.count > 0 else { closure?(0, nil, error); return }
        
        let api = apiOrders[0]
        let leftApis = apiOrders.filter{ $0 != api }
        switch api {
        case .blockcypher:
            let request = BlockcypherFeeRequest()
            request.path = network == .mainnet ? "/main" : "/test3"
            BlockcypherNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BlockcypherFee.self) {
                    closure?(model.toBtcTxFee(), model.toBitcoinFee(), response.error)
                } else {
                    self.getTxFee(apiOrders: leftApis, error: error ?? response.error, network: network, closure: closure)
                }
            }
        case .bitcoinfees:
            let request = BitcoinfeesRequest()
            BitcoinfeesNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BitcoinFees.self) {
                    closure?(model.toBtcTxFee(), model, response.error)
                } else {
                    self.getTxFee(apiOrders: leftApis, error: error ?? response.error, network: network, closure: closure)
                }
            }
        case .blockexplorer:
            let request = BlockexplorerFeeRequest()
            request.path = "\(network.network(api: api))blockexplorer.com/api/utils/estimatefee?nbBlocks=3"
            BlockexplorerNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BlockexplorerFee.self) {
                    closure?(model.toBtcTxFee(), nil, response.error)
                } else {
                    self.getTxFee(apiOrders: leftApis, error: error ?? response.error, network: network, closure: closure)
                }
            }
        case .eNotes:
            eNotesNetworkManager.shared.getTxFee(api: api, network: network, closure: closure)
        default:
            break
        }
    }
    
    func sendTransaction(apiOrder: [ApiType] = BtcSendTxApis, error: NSError? = nil, network: Network, rawtx: String, closure: txIdClosure) {
        guard apiOrder.count > 0 else { closure?("", error); return }
        
        let api = apiOrder[0]
        let leftApis = apiOrder.filter{ $0 != api }
        switch api {
        case .blockcypher:
            let request = BlockcypherSendTxRequest()
            request.path = "/\(network.network(api: api))/txs/push?token=\(BlockcypherApiKeys.random())"
            request.tx = rawtx
            BlockcypherNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BlockcypherTxidRaw.self) {
                    closure?(model.toTxId(), response.error)
                } else {
                    self.sendTransaction(apiOrder: leftApis, error: error ?? response.error, network: network, rawtx: rawtx, closure: closure)
                }
            }
        case .blockexplorer:
            let request = BlockexplorerSendTxRequest()
            request.path = "\(network.network(api: api))blockexplorer.com/api/tx/send"
            request.rawtx = rawtx
            BlockexplorerNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BlockexplorerTxid.self) {
                    closure?(model.toTxId(), response.error)
                } else {
                    self.sendTransaction(apiOrder: leftApis, error: error ?? response.error, network: network, rawtx: rawtx, closure: closure)
                }
            }
        case .eNotes:
            eNotesNetworkManager.shared.sendTransaction(blockchain: .bitcoin, network: network, rawtx: rawtx, closure: closure)
        default:
            break
        }
    }
    
    func getTxReceipt(apis: [ApiType] = BtcSendTxApis, error: NSError? = nil, blockchain: Blockchain, network: Network, txid: String, closure: txReceiptClosure) {
        guard apis.count > 0 else { closure?(.none, error); return }
        
        let api = apis[0]
        let leftApis = apis.filter{ $0 != api }
        switch api {
        case .blockcypher:
            let request = BlockcypherTxReceiptRequest()
            request.path = "/\(network.network(api: api))/txs/\(txid)?token=\(BlockcypherApiKeys.random())"
            BlockcypherNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BlockexplorerTxReceipt.self) {
                    closure?(model.toConfirmStatus(), response.error)
                } else {
                    self.getTxReceipt(apis: leftApis, error: error ?? response.error, blockchain: blockchain, network: network, txid: txid, closure: closure)
                }
            }
        case .blockexplorer:
            let request = BlockexplorerTxReceiptRequest()
            request.path = "\(network.network(api: api))blockexplorer.com/api/tx/\(txid)"
            BlockexplorerNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BlockexplorerTxReceipt.self) {
                    closure?(model.toConfirmStatus(), response.error)
                } else {
                    self.getTxReceipt(apis: leftApis, error: error ?? response.error, blockchain: blockchain, network: network, txid: txid, closure: closure)
                }
            }
        case .eNotes:
            eNotesNetworkManager.shared.getTxReceipt(blockchain: blockchain, network: network, txid: txid, closure: closure)
        default:
            break
        }
    }
    
    func getTransactionHistory(apis: [ApiType] = DefaultBtcTxsApiOrder, error: NSError? = nil, network: Network, address: String, closure: txsClosure) {
        guard apis.count > 0 else { closure?(nil, error); return }
        
        let api = apis[0]
        let leftApis = apis.filter{ $0 != api }
        switch api {
        case .blockcypher:
            let request = BlockcypherTxsRequest()
            request.path = "/\(network.network(api: api))/addrs/\(address)?token=\(BlockcypherApiKeys.random())&limit=51"
            BlockcypherNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BlockcypherTxsRaw.self) {
                    closure?(model.toTransactionHistory(address: address), response.error)
                } else {
                    self.getTransactionHistory(apis: leftApis, error: error ?? response.error, network: network, address: address, closure: closure)
                }
            }
        case .blockexplorer:
            let request = BlockexplorerTxsRequest()
            request.path = "\(network.network(api: api))blockexplorer.com/api/addrs/\(address)/txs/?from=0&to=51"
            BlockexplorerNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BlockexplorerTxsRaw.self) {
                    closure?(model.toTransactionHistory(address: address), response.error)
                } else {
                    self.getTransactionHistory(apis: leftApis, error: error ?? response.error, network: network, address: address, closure: closure)
                }
            }
        default:
            break
        }
    }
}
