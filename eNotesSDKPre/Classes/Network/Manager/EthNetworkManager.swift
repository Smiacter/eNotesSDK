//
//  EthNetworkManager.swift
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

class EthNetworkManager: NSObject {
    static let shared = EthNetworkManager()
    private override init() {
        
    }
}

extension EthNetworkManager {
    
    /// Get eth gas price
    ///
    /// - Parameters:
    ///  - apiOrder: array, define request api order, default set in NetworkDefinition.swift
    ///  - network: blockchain network
    /// - return: string type gas price throungh gasPriceClosure
    func getGasPrice(apiOrder: [ApiType] = DefaultGasPriceApiOrder, error: NSError? = nil, network: Network, closure: ethGasPriceClosure) {
        guard apiOrder.count > 0 else { closure?("", nil, error); return }
        
        let api = apiOrder[0]
        let leftApis = apiOrder.filter{ $0 != api }
        switch api {
        case .etherchain:
            EtherchainNetwork.request(EtherchainGasPriceRequest()) { (response) in
                let error = response.error
                if let model = response.decode(to: EtherchainGasPrice.self) {
                    closure?(model.toGasPrice(), model, response.error)
                } else {
                    self.getGasPrice(apiOrder: leftApis, error: error ?? response.error, network: network, closure: closure)
                }
            }
        case .infura:
            let request = InfuraGasPriceRequest()
            request.path = "/\(network.network(api: api))/eth_gasPrice?token=\(NetworkManager.shared.apiKeyConfig.infuraApiKeys.random())"
            InfuraNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraGasPrice.self) {
                    closure?(model.toGasPrice(), nil, response.error)
                } else {
                    self.getGasPrice(apiOrder: leftApis, error: error ?? response.error, network: network, closure: closure)
                }
            }
        case .etherscan:
            let request = EtherscanGasPriceRequest()
            request.path = "\(network.network(api: api)).etherscan.io/api?module=proxy&action=eth_gasPrice&apikey=\(NetworkManager.shared.apiKeyConfig.etherscanApiKeys.random())"
            EtherscanNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraGasPrice.self) {
                    closure?(model.toGasPrice(), nil, response.error)
                } else {
                    self.getGasPrice(apiOrder: leftApis, error: error ?? response.error, network: network, closure: closure)
                }
            }
        case .eNotes:
            eNotesNetworkManager.shared.getGasPrice(api: api, network: network, closure: closure)
        default:
            break
        }
    }
    
    func call(apiOrder: [ApiType] = DefaultEthApiOrder, error: NSError? = nil, network: Network, toAddress: String, data: String?, closure: ethCallClosure) {
        guard apiOrder.count > 0, let dataStr = data else { closure?("", error); return }
        
        let api = apiOrder[0]
        let leftApis = apiOrder.filter{ $0 != api }
        switch api {
        case .infura:
            let request = InfuraCallRequest()
            request.path = "/\(network.network(api: api))?token=\(NetworkManager.shared.apiKeyConfig.infuraApiKeys.random())"
            request.parameters = ["jsonrpc": JsonRpcVersion, "method": "eth_call", "id": InfuraId, "params": [["to": toAddress, "data": dataStr.addHexPrefix()], "latest"]]
            InfuraNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraGasPrice.self) {
                    closure?(model.result, response.error)
                } else {
                    self.call(apiOrder: leftApis, error: error ?? response.error, network: network, toAddress: toAddress, data: data, closure: closure)
                }
            }
        case .etherscan:
            let request = EtherscanCallRequest()
            request.path = "\(network.network(api: api)).etherscan.io/api?module=proxy&action=eth_call&to=\(toAddress)&data=\(dataStr.addHexPrefix())&tag=latest&apikey=\(NetworkManager.shared.apiKeyConfig.etherscanApiKeys.random())"
            EtherscanNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraGasPrice.self) {
                    closure?(model.result, response.error)
                } else {
                    self.call(apiOrder: leftApis, error: error ?? response.error, network: network, toAddress: toAddress, data: data, closure: closure)
                }
            }
        case .eNotes:
            eNotesNetworkManager.shared.call(api: api, network: network, toAddress: toAddress, dataStr: dataStr, closure: closure)
        default:
            break
        }
    }
    
    func getNonce(apiOrder: [ApiType] = DefaultEthApiOrder, error: NSError? = nil, network: Network, address: String, closure: ethNonceClosure) {
        guard apiOrder.count > 0 else { closure?(0, error); return }
        
        let api = apiOrder[0]
        let leftApis = apiOrder.filter{ $0 != api }
        switch api {
        case .infura:
            let request = InfuraNonceRequest()
            request.path = "/\(network.network(api: api))/eth_getTransactionCount?token=\(NetworkManager.shared.apiKeyConfig.infuraApiKeys.random())&params=[\"\(address)\",\"latest\"]".urlEncoded()
            InfuraNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraGasPrice.self) {
                    closure?(model.toNonce(), response.error)
                } else {
                    self.getNonce(apiOrder: leftApis, error: error ?? response.error, network: network, address: address, closure: closure)
                }
            }
        case .etherscan:
            let request = EtherscanCallRequest()
            request.path = "\(network.network(api: api)).etherscan.io/api?module=proxy&action=eth_getTransactionCount&address=\(address)&tag=latest&apikey=\(NetworkManager.shared.apiKeyConfig.etherscanApiKeys.random())"
            EtherscanNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraGasPrice.self) {
                    closure?(model.toNonce(), response.error)
                } else {
                    self.getNonce(apiOrder: leftApis, error: error ?? response.error, network: network, address: address, closure: closure)
                }
            }
        case .eNotes:
            eNotesNetworkManager.shared.getNonce(api: api, network: network, address: address, closure: closure)
        default:
            break
        }
    }
    
    func getEstimateGas(apiOrder: [ApiType] = DefaultEthApiOrder, error: NSError? = nil, network: Network, from: String, to address: String, value: String, data: String? = nil, closure: ethEstimateGasClosure) {
        guard apiOrder.count > 0 else { closure?("", error); return }
        
        let api = apiOrder[0], dataStr = data != nil ? "&data=\(data!)" : ""
        let leftApis = apiOrder.filter{ $0 != api }
        switch api {
        case .infura:
            let request = InfuraEstimateGasRequest()
            request.path = "/\(network.network(api: api))?token=\(NetworkManager.shared.apiKeyConfig.infuraApiKeys.random())"
            request.parameters = ["jsonrpc": JsonRpcVersion, "method": "eth_estimateGas", "id": InfuraId, "params": [["from":from, "to": address, "value": value, "data": data]]]
            InfuraNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraGasPrice.self) {
                    closure?(model.toEstimateGas(), response.error)
                } else {
                    self.getEstimateGas(apiOrder: leftApis, error: error ?? response.error, network: network, from: from, to: address, value: value, closure: closure)
                }
            }
        case .etherscan:
            let request = EtherscanEstimateGasRequest()
            request.path = "\(network.network(api: api)).etherscan.io/api?module=proxy&action=eth_estimateGas&from=\(from)&to=\(address)&value=\(value)\(dataStr)&apikey=\(NetworkManager.shared.apiKeyConfig.etherscanApiKeys.random())"
            EtherscanNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraGasPrice.self) {
                    closure?(model.toEstimateGas(), response.error)
                } else {
                    self.getEstimateGas(apiOrder: leftApis, error: error ?? response.error, network: network, from: from, to: address, value: value, closure: closure)
                }
            }
        case .eNotes:
            eNotesNetworkManager.shared.getEstimateGas(api: api, network: network, from: from, to: address, value: value, data: data, closure: closure)
        default:
            break
        }
    }
    
    func getBalance(apiOrder: [ApiType] = DefaultEthApiOrder, error: NSError? = nil, blockchain: Blockchain, network: Network, address: String, closure: balanceClosure) {
        guard apiOrder.count > 0 else { closure?("", error); return }
        
        let api = apiOrder[0]
        let leftApis = apiOrder.filter{ $0 != api }
        switch api {
        case .infura:
            let request = InfuraBalanceRequest()
            request.path = "/\(network.network(api: api))/eth_getBalance?token=\(NetworkManager.shared.apiKeyConfig.infuraApiKeys.random())&params=[\"\(address)\",\"latest\"]".urlEncoded()
            InfuraNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraGasPrice.self) {
                    closure?(model.toBalance(), response.error)
                } else {
                    self.getBalance(apiOrder: leftApis, error: error ?? response.error, blockchain: blockchain, network: network, address: address, closure: closure)
                }
            }
        case .etherscan:
            let request = EtherscanBalanceRequest()
            request.path = "\(network.network(api: api)).etherscan.io/api?module=account&action=balance&address=\(address)&tag=latest&apikey=\(NetworkManager.shared.apiKeyConfig.etherscanApiKeys.random())"
            EtherscanNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: EtherscanBalance.self) {
                    closure?(model.toBalance(), response.error)
                } else {
                    self.getBalance(apiOrder: leftApis, error: error ?? response.error, blockchain: blockchain, network: network, address: address, closure: closure)
                }
            }
        case .eNotes:
            eNotesNetworkManager.shared.getBalance(blockchain: blockchain, network: network, address: address, closure: closure)
        default:
            break
        }
    }
    
    /// get mult address balance
    func getMultBalances(network: Network, addresses: [String], closure: multBalanceClosure) {
        let addressStr = EnoteFormatter.packingArrToString(arr: addresses, seperator: ",")
        let request = EtherscanBalanceRequest()
        request.path = "\(network.network(api: .etherscan)).etherscan.io/api?module=account&action=balancemulti&address=\(addressStr)&tag=latest&apikey=\(NetworkManager.shared.apiKeyConfig.etherscanApiKeys.random())"
        EtherscanNetwork.request(request) { (response) in
            guard response.error == nil else { closure?(nil, response.error); return }
            guard let model = response.decode(to: EtherscanMultBalanceRaw.self) else { closure?(nil, response.error); return }
            closure?(model.toMultBalance(), response.error)
        }
    }
    
    func sendTransaction(apiOrder: [ApiType] = DefaultEthApiOrder, error: NSError? = nil, network: Network, rawtx: String, closure: txIdClosure) {
        guard apiOrder.count > 0 else { closure?("", error); return }
        
        let api = apiOrder[0]
        let leftApis = apiOrder.filter{ $0 != api }
        switch api {
        case .infura:
            let request = InfuraSendTxRequest()
            request.path = "/\(network.network(api: api))?token=\(NetworkManager.shared.apiKeyConfig.infuraApiKeys.random())"
            request.parameters = ["jsonrpc": JsonRpcVersion, "method": "eth_sendRawTransaction", "id": InfuraId, "params": ["\(rawtx)"]]
            InfuraNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraGasPrice.self) {
                    closure?(model.toTxId(), response.error)
                } else {
                    self.sendTransaction(apiOrder: leftApis, error: error ?? response.error, network: network, rawtx: rawtx, closure: closure)
                }
            }
        case .etherscan:
            let request = EtherscanSendTxRequest()
            request.path = "\(network.network(api: api)).etherscan.io/api?module=proxy&action=eth_sendRawTransaction&apikey=\(NetworkManager.shared.apiKeyConfig.etherscanApiKeys.random())"
            request.hex = rawtx
            EtherscanNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraGasPrice.self) {
                    closure?(model.toTxId(), response.error)
                } else {
                    self.sendTransaction(apiOrder: leftApis, error: error ?? response.error, network: network, rawtx: rawtx, closure: closure)
                }
            }
        case .eNotes:
            eNotesNetworkManager.shared.sendTransaction(blockchain: .ethereum, network: network, rawtx: rawtx, closure: closure)
        default:
            break
        }
    }
    
    func getTxReceipt(apiOrder: [ApiType] = DefaultEthApiOrder, error: NSError? = nil, blockchain: Blockchain, network: Network, txid: String, closure: txReceiptClosure) {
        guard apiOrder.count > 0 else { closure?(.none, error); return }
        
        let api = apiOrder[0]
        let leftApis = apiOrder.filter{ $0 != api }
        switch api {
        case .infura:
            let request = InfuraTxReceiptRequest()
            request.path = "/\(network.network(api: api))/eth_getTransactionReceipt?token=\(NetworkManager.shared.apiKeyConfig.infuraApiKeys.random())&params=[\"\(txid)\"]".urlEncoded()
            InfuraNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraTxReceiptRaw.self) {
                    closure?(model.toConfirmStatus(), response.error)
                } else {
                    self.getTxReceipt(apiOrder: leftApis, error: error ?? response.error, blockchain: blockchain, network: network, txid: txid, closure: closure)
                }
            }
        case .etherscan:
            let request = EtherscanTxReceiptRequest()
            request.path = "\(network.network(api: api)).etherscan.io/api?module=proxy&action=eth_getTransactionReceipt&apikey=\(NetworkManager.shared.apiKeyConfig.etherscanApiKeys.random())&txhash=\(txid)"
            EtherscanNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: InfuraTxReceiptRaw.self) {
                    closure?(model.toConfirmStatus(), response.error)
                } else {
                    self.getTxReceipt(apiOrder: leftApis, error: error ?? response.error, blockchain: blockchain, network: network, txid: txid, closure: closure)
                }
            }
        case .eNotes:
            eNotesNetworkManager.shared.getTxReceipt(blockchain: blockchain, network: network, txid: txid, closure: closure)
        default:
            break
        }
    }
    
    func getTransactionHistory(network: Network, address: String, contract: String?, closure: txsClosure) {
        var path = ""
        if contract == nil {
            path = "\(network.network(api: .etherscan)).etherscan.io/api?module=account&action=txlist&address=\(address)&page=1&offset=51&sort=desc&apikey=\(NetworkManager.shared.apiKeyConfig.etherscanApiKeys.random())"
        } else {
            path = "\(network.network(api: .etherscan)).etherscan.io/api?module=account&action=tokentx&contractaddress=\(contract!)&address=\(address)&page=1&offset=51&sort=desc&apikey=\(NetworkManager.shared.apiKeyConfig.etherscanApiKeys.random())"
        }
        
        let request = EtherscanTxsRequest()
        request.path = path
        EtherscanNetwork.request(request) { (response) in
            guard response.error == nil else { closure?(nil, response.error); return }
            guard let model = response.decode(to: EtherscanTxsRaw.self) else { closure?(nil, response.error); return }
            closure?(model.toTransactionHistory(address: address), nil)
        }
    }
}
