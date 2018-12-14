//
//  NetworkManager.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/14.
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

/// Balance callabck, String: hex string balance, NSError?: network or decode error
public typealias balanceClosure = ((String, NSError?) -> ())?
public typealias multBalanceClosure = (([MultiBalance]?, NSError?) -> ())?
/// Transaction Receipt callback, ConfirmStatus: receipt status, NSError?: network or decode error
public typealias txReceiptClosure = ((ConfirmStatus, NSError?) -> ())?
/// TxId callback when send raw transaction success, String: txid, NSError?: network or decode error
public typealias txIdClosure = ((String, NSError?) -> ())?
/// unspend callback, [UtxoModel]: uxto array, NSError?: network or decode error
public typealias btcUtxosClosure = (([UtxoModel], NSError?) -> ())?
/// estimate fee callback, Int64: default return halfHourFee or mediumFee, BitcoinFees?: model include hourFee, halfHourFee, fastestFee you can choose which one to use, NSError?: network or decode error
public typealias btcTxFeeClosure = ((Int64, BitcoinFees?, NSError?) -> ())?
/// gas price callback, String: hex string gas price, default reaturn fast, EtherchainGasPrice?: model include safeLow, standard, fast, fastest, you can choose which one to use, NSError?: network or decode error
public typealias ethGasPriceClosure = ((String, EtherchainGasPrice?, NSError?) -> ())?
/// nonce callback, UInt: nonce, NSError?: network or decode error
public typealias ethNonceClosure = ((UInt, NSError?) -> ())?
/// estimate gas callabck, String: hex string estimate gas, NSError?: network or decode error
public typealias ethEstimateGasClosure = ((String, NSError?) -> ())?
/// call, String: call result, NSError?: network or decode error
public typealias ethCallClosure = ((String, NSError?) -> ())?
/// blockchain exchange rate, Double?: rate, NSError?: network or decode error
public typealias exchangeRateClosure = ((ExchangeRate?, RateApi?, NSError?) -> ())?
/// blockchain transaction history, list of transaction history, NSError?: network or decode error
public typealias txsClosure = (([TransactionHistory]?, NSError?) -> ())?

public class NetworkManager: NSObject {
    static public let shared = NetworkManager()
    private override init() {
        
    }
    
    var apiKeyConfig = ApiKeyConfig(etherscanApiKeys: EtherscanApiKeys, infuraApiKeys: InfuraApiKeys, blockcypherApiKeys: BlockcypherApiKeys)
    
    private let reachabilityManager = NetworkReachabilityManager()
    
    func startReachablilityListening() {
        reachabilityManager?.listener = { status in
            switch status {
            case .unknown, .notReachable:
                break
            default:
                break
                // TODO: reconnect ?
            }
        }
        reachabilityManager?.startListening()
    }
    
    public func isReachable() -> Bool {
        return reachabilityManager?.isReachable ?? false
    }
}

// MARK: Universal

public extension NetworkManager {
    
    /// Config third api key, we provide default value, but you'd better provide yours
    /// We use several rpc api to request, some api need api key, so you'd better config it
    ///
    /// - Parameters:
    ///  - config: api key config
    func setNetwork(config: ApiKeyConfig) {
        apiKeyConfig = config
    }
    
    /// Get specified balance
    ///
    /// - Parameters:
    ///  - blockchain: btc or eth, see Blockchain
    ///  - network: mainnet, ethereum... see NetworkType
    ///  - address: sender unique address
    ///  - closure: balance result callback
    ///   - String: hex format balance
    ///   - NSError?: network or decode error if occurred
    func getBalance(blockchain: Blockchain, network: Network, address: String, closure: balanceClosure) {
        switch blockchain {
        case .bitcoin:
            BtcNetworkManager.shared.getBalance(blockchain: blockchain, network: network, address: address, closure: closure)
        case .ethereum:
            EthNetworkManager.shared.getBalance(blockchain: blockchain, network: network, address: address, closure: closure)
        }
    }
    func getMultBalances(blockchain: Blockchain, network: Network, addresses: [String], closure: multBalanceClosure) {
        switch blockchain {
        case .bitcoin:
            BtcNetworkManager.shared.getMultBalances(network: network, addresses: addresses, closure: closure)
        case .ethereum:
            EthNetworkManager.shared.getMultBalances(network: network, addresses: addresses, closure: closure)
        }
    }
    
    /// Send transaction to other address, maybe you call withdraw
    ///
    /// - Parameters:
    ///  - blockchain: btc or eth, see Blockchain
    ///  - network: mainnet, ethereum... see Network
    ///  - rawtx: signed transaction info
    ///  - closure: transaction send result callback
    ///   - String: transaction id
    ///   - NSError?: network or decode error if occurred
    func sendRawTransaction(blockchain: Blockchain, network: Network, rawtx: String, closure: txIdClosure) {
        switch blockchain {
        case .bitcoin:
            BtcNetworkManager.shared.sendTransaction(network: network, rawtx: rawtx, closure: closure)
        case .ethereum:
            EthNetworkManager.shared.sendTransaction(network: network, rawtx: rawtx, closure: closure)
        }
    }
    
    /// Get transaction receipt status
    ///
    /// - Parameters:
    ///  - blockchain: btc or eth, see Blockchain
    ///  - network: mainnet, ethereum... see Network
    ///  - txid: transaction id
    ///  - closure: receipt result callback
    ///   - ConfirmStatus: confirmed or confirming, see ConfirmStatus
    ///   - NSError?: network or decode error if occurred
    func getTransactionReceipt(blockchain: Blockchain, network: Network, txid: String, closure: txReceiptClosure) {
        switch blockchain {
        case .bitcoin:
            BtcNetworkManager.shared.getTxReceipt(blockchain: blockchain, network: network, txid: txid, closure: closure)
        case .ethereum:
            EthNetworkManager.shared.getTxReceipt(blockchain: blockchain, network: network, txid: txid, closure: closure)
        }
    }
    
    /// Get transaction history
    ///
    /// - Parameters:
    ///  - blockchain: btc or eth, see Blockchain
    ///  - network: mainnet, ethereum... see Network
    ///  - address: specified address
    ///  - contract: contract address if have
    ///  - closure: receipt result callback
    ///   - [TransactionHistory]: confirmed or confirming, see ConfirmStatus
    ///   - NSError?: network or decode error if occurred
    func getTransactionHistory(blockchain: Blockchain, network: Network, address: String, contract: String?, closure: txsClosure) {
        switch blockchain {
        case .bitcoin:
            BtcNetworkManager.shared.getTransactionHistory(network: network, address: address, closure: closure)
        case .ethereum:
            EthNetworkManager.shared.getTransactionHistory(network: network, address: address, contract: contract, closure: closure)
        }
    }
    
    func subscribeNotification(blockchain: Blockchain, clientId: String, network: Network, txid: String) {
        eNotesNetworkManager.shared.subscribeNotification(blockchain: blockchain, clientId: clientId, network: network, txid: txid)
    }
}

// MARK: Btc

public extension NetworkManager {
    
    /// Get unspend, utxo array
    ///
    /// - Parameters:
    ///  - network: mainnet, ethereum... see Network
    ///  - address: send address
    ///  - closure: utxos result callback
    ///   - [UtxoModel]: utxo array
    ///   - NSError?: network or decode error if occurred
    func getUnspend(network: Network, address: String, closure: btcUtxosClosure) {
        BtcNetworkManager.shared.getUtxos(network: network, address: address, closure: closure)
    }

    /// Get transaction estimate fee
    ///
    /// - Parameters:
    ///  - network: mainnet, ethereum... see Network
    ///  - closure: estimate fee result callback
    ///   - Int64: default return halfHour fee, per kb
    ///   - BitcoinFees?: estimate fee full information including fastestFee, halfHourFee, hourFee
    ///   - NSError?: network or decode error if occurred
    func getEstimateFee(network: Network, closure: btcTxFeeClosure) {
        BtcNetworkManager.shared.getEstimateFee(network: network, closure: closure)
    }
}

// MARK: Eth

public extension NetworkManager {
    
    /// Get gas price
    ///
    /// - Parameters:
    ///  - network: mainnet, ethereum... see Network
    ///  - closure: gasPrice result callback
    ///   - String: default is fast price, hex string value
    ///   - EtherchainGasPrice: price model include full information including safeLow, standard, fast, fastest
    ///   - NSError?: network or decode error if occurred
    func getGasPrice(network: Network, closure: ethGasPriceClosure) {
        EthNetworkManager.shared.getGasPrice(network: network, closure: closure)
    }
    
    /// Eth call
    ///
    /// - Parameters:
    ///  - network: mainnet, ethereum... see Network
    ///  - toAddress: to contract address
    ///  - data: contract encoded data string
    ///  - closure: call result callback
    ///   - String: call result
    ///   - NSError?: network or decode error if occurred
    func call(network: Network, toAddress: String, data: String?, closure: ethCallClosure) {
        EthNetworkManager.shared.call(network: network, toAddress: toAddress, data: data, closure: closure)
    }
    
    /// Get nonce
    ///
    /// - Parameters:
    ///  - network: mainnet, ethereum... see Network
    ///  - address: sender address
    ///  - closure: eth nonce result callback
    ///   - UInt: eth nonce
    ///   - NSError?: network or decode error if occurred
    func getNonce(network: Network, address: String, closure: ethNonceClosure) {
        EthNetworkManager.shared.getNonce(network: network, address: address, closure: closure)
    }
    
    /// Get estimate gas
    ///
    /// - Parameters:
    ///  - network: mainnet, ethereum... see Network
    ///  - from: sender address
    ///  - to: destination address
    ///  - value: transaction amout
    ///  - data?: contract abi encode data
    ///  - closure: eth estimateGas result callback
    ///   - String: eth estimate gas, hex string value
    ///   - NSError?: network or decode error if occurred
    func getEstimateGas(network: Network, from: String, to: String, value: String, data: String? = nil, closure: ethEstimateGasClosure) {
        EthNetworkManager.shared.getEstimateGas(network: network, from: from, to: to, value: value, data: data, closure: closure)
    }
}

// MARK: Exchange Rate

extension NetworkManager {
    
    public func getExchangeRate(blockchain: Blockchain, isToken: Bool = false, closure: exchangeRateClosure) {
        if isToken {
            getExchangeRate(apiOrder: GusdRateApiOrder, blockchain: blockchain, isToken: isToken, closure: closure)
        } else {
            getExchangeRate(apiOrder: DefaultRateApiOrder, blockchain: blockchain, isToken: isToken, closure: closure)
        }
    }
    
    private func getExchangeRate(apiOrder: [RateApi] = DefaultRateApiOrder, error: NSError? = nil, blockchain: Blockchain, isToken: Bool = false, closure: exchangeRateClosure) {
        guard apiOrder.count > 0 else { closure?(nil, nil, error); return }
        
        let api = apiOrder[0]
        let leftApis = apiOrder.filter{ $0 != api }
        switch api {
        case .coinbase:
            let request = CoinbaseRateRequest()
            request.path = "\(blockchain.short)"
            CoinbaseNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: CoinbaseRaw.self) {
                    closure?(model.toExchangeRate(), api, nil)
                } else {
                    self.getExchangeRate(apiOrder: leftApis, error: error ?? response.error, blockchain: blockchain, closure: closure)
                }
            }
        case .okex:
            getOkexRate(blockchain: blockchain, isToken: isToken) { (rate, type, error) in
                guard error == nil else {
                    self.getExchangeRate(apiOrder: leftApis, error: error, blockchain: blockchain, closure: closure)
                    return
                }

                closure?(rate, api, nil)
            }
        case .bitz:
            let request = BitzRateRequest()
            request.path = "\(blockchain.short.lowercased())"
            BitzNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: BitzRaw.self) {
                    closure?(model.toExchangeRate(), api, nil)
                } else {
                    self.getExchangeRate(apiOrder: leftApis, error: error ?? response.error, blockchain: blockchain, closure: closure)
                }
            }
        case .cryptocompare:
            let request = CryptoCompareRequest()
            let type = isToken ? "GUSD" : "\(blockchain.short)"
            request.path = "fsyms=\(type)&tsyms=USD,CNY,EUR,JPY,BTC,ETH,GUSD"
            CryptoCompareNetwork.request(request) { (response) in
                let error = response.error
                if let model = response.decode(to: CryptoCompare.self) {
                    closure?(model.toExchangeRate(), api, nil)
                } else {
                    self.getExchangeRate(apiOrder: leftApis, error: error ?? response.error, blockchain: blockchain, closure: closure)
                }
            }
        }
    }
    
    private func getOkexRate(blockchain: Blockchain, isToken: Bool = false, closure: exchangeRateClosure) {
        var gusd2btcRate: Double?
        var eth2btcRate: Double?
        var btc2usdRate: Double?
        var curreny: Usd2OtherCurrency?
        let group = DispatchGroup()

        // get rate of gusd to btc and eth to btc
        group.enter()
        let toBtcRequest = OkexOther2BtcRequest()
        toBtcRequest.path = "/spot/v3/instruments/ticker" // GUSD-BTC , ETH-BTC
        OkexNetwork.request(toBtcRequest) { (response) in
            group.leave()
            if let model = response.decode(to: [OkexOther2Btc].self) {
                let gusd2Btc = model.filter { $0.instrument_id == "GUSD-BTC" }
                let eth2Btc = model.filter { $0.instrument_id == "ETH-BTC" }
                if gusd2Btc.count == 1 {
                    gusd2btcRate = Double(gusd2Btc[0].last)
                }
                if eth2Btc.count == 1 {
                    eth2btcRate = Double(eth2Btc[0].last)
                }
            }
        }
        // get btc to usd rate
        group.enter()
        let toUsdRequest = OkexOther2UsdRequest()
        toUsdRequest.path = "/v1/future_index.do?symbol=btc_usd"
        OkexNetwork.request(toUsdRequest) { (response) in
            group.leave()
            if let model = response.decode(to: OkexOther2Usd.self) {
                btc2usdRate = model.future_index
            }
        }
        // get rate of usd to USD, CNY, EUR, JPY
        group.enter()
        getUsd2OtherCurrency { (usd2OtherCurrency) in
            group.leave()
            curreny = usd2OtherCurrency
        }

        group.notify(queue: .main) {
            guard let gusd2btcRate = gusd2btcRate, let eth2btcRate = eth2btcRate,
                let btc2usdRate = btc2usdRate, let curreny = curreny else {
                let error = NSError(domain: "okex rate get failed", code: -10086, userInfo: nil)
                closure?(nil, nil, error)
                return
            }
            /// gusd
            guard !isToken else {
                let gusd: Double = 1
                let btc = gusd2btcRate
                let eth = gusd2btcRate / eth2btcRate
                let usd = gusd2btcRate * btc2usdRate
                let cny = usd * curreny.usd2cny
                let eur = usd * curreny.usd2eur
                let jpy = usd * curreny.usd2jpy
                let exchangeRate = ExchangeRate(btc: btc,
                                                eth: eth,
                                                gusd: gusd,
                                                usd: usd,
                                                cny: cny,
                                                eur: eur,
                                                jpy: jpy)
                closure?(exchangeRate, .okex, nil)
                return
            }
            // btc or eth
            switch blockchain {
            case .bitcoin:
                let btc: Double = 1
                let eth = 1 / eth2btcRate
                let gusd = 1 / gusd2btcRate
                let usd = btc2usdRate
                let cny = usd * curreny.usd2cny
                let eur = usd * curreny.usd2eur
                let jpy = usd * curreny.usd2jpy
                let exchangeRate = ExchangeRate(btc: btc,
                                                eth: eth,
                                                gusd: gusd,
                                                usd: usd,
                                                cny: cny,
                                                eur: eur,
                                                jpy: jpy)
                closure?(exchangeRate, .okex, nil)
            case .ethereum:
                let eth: Double = 1
                let btc = eth2btcRate
                let gusd = eth2btcRate / gusd2btcRate
                let usd = eth2btcRate * btc2usdRate
                let cny = usd * curreny.usd2cny
                let eur = usd * curreny.usd2eur
                let jpy = usd * curreny.usd2jpy
                let exchangeRate = ExchangeRate(btc: btc,
                                                eth: eth,
                                                gusd: gusd,
                                                usd: usd,
                                                cny: cny,
                                                eur: eur,
                                                jpy: jpy)
                closure?(exchangeRate, .okex, nil)
            }
        }
    }
    
    private typealias usd2otherClosure = ((Usd2OtherCurrency?) -> ())?
    private func getUsd2OtherCurrency(apiOrder: [RateApi] = Usd2OtherApiOrder, closure: usd2otherClosure) {
        guard apiOrder.count > 0 else { return }
        let api = apiOrder[0]
        let leftApis = apiOrder.filter{ $0 != api }
        switch api {
        case .bitz:
            let request = BitzRateRequest()
            request.path = "eth"
            BitzNetwork.request(request) { (response) in
                if let model = response.decode(to: BitzRaw.self) {
                    closure?(model.toUsd2Other())
                } else {
                    self.getUsd2OtherCurrency(apiOrder: leftApis, closure: closure)
                }
            }
        case .cryptocompare:
            let request = CryptoCompareRequest()
            request.path = "fsyms=ETH&tsyms=USD,CNY,EUR,JPY"
            CryptoCompareNetwork.request(request) { (response) in
                if let model = response.decode(to: CryptoCompare.self) {
                    closure?(model.toUsd2Other())
                } else {
                    self.getUsd2OtherCurrency(apiOrder: leftApis, closure: closure)
                }
            }
        default:
            break
        }
    }
}
