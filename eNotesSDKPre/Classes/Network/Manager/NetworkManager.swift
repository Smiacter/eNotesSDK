//
//  NetworkManager.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/14.
//  Copyright © 2018 Smiacter. All rights reserved.
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
    
    func isReachable() -> Bool {
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
        guard isReachable() else { return }
        switch blockchain {
        case .bitcoin:
            BtcNetworkManager.shared.getBalance(blockchain: blockchain, network: network, address: address, closure: closure)
        case .ethereum:
            EthNetworkManager.shared.getBalance(blockchain: blockchain, network: network, address: address, closure: closure)
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
        guard isReachable() else { return }
        switch blockchain {
        case .bitcoin:
            BtcNetworkManager.shared.getTxReceipt(blockchain: blockchain, network: network, txid: txid, closure: closure)
        case .ethereum:
            EthNetworkManager.shared.getTxReceipt(blockchain: blockchain, network: network, txid: txid, closure: closure)
        }
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
