//
//  NetworkManager.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/14.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import UIKit
import Alamofire

public typealias balanceClosure = ((String, NSError?) -> ())?
public typealias confirmedClosure = ((ConfirmStatus, NSError?) -> ())?
public typealias txIdClosure = ((String, NSError?) -> ())?
public typealias btcUtxosClosure = (([UtxoModel], NSError?) -> ())?
public typealias btcTxFeeClosure = ((Int64, BitcoinFees?, NSError?) -> ())?
public typealias ethGasPriceClosure = ((String, EtherchainGasPrice?, NSError?) -> ())?
public typealias ethNonceClosure = ((UInt, NSError?) -> ())?
public typealias ethEstimateGasClosure = ((String, NSError?) -> ())?
public typealias ethCallClosure = ((String, NSError?) -> ())?

public class NetworkManager: NSObject {
    static public let shared = NetworkManager()
    private override init() {
        
    }
    
    var apiKeyConfig = ApiKeyConfig(etherscanApiKeys: EtherscanApiKeys, infuraApiKeys: InfuraApiKeys, blockcypherApiKeys: BlockcypherApiKeys)
    private let reachabilityManager = NetworkReachabilityManager()
    public var reconnectClosure: (() -> ())?
    
    public func setNetwork(config: ApiKeyConfig) {
        apiKeyConfig = config
    }
}

// MARK: Universal

public extension NetworkManager {
    
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
    
    func getBalance(blockchain: Blockchain, network: Network, address: String, closure: balanceClosure) {
        guard isReachable() else { return }
        switch blockchain {
        case .bitcoin:
            BtcNetworkManager.shared.getBalance(blockchain: blockchain, network: network, address: address, closure: closure)
        case .ethereum:
            EthNetworkManager.shared.getBalance(blockchain: blockchain, network: network, address: address, closure: closure)
        }
    }
    
    func sendRawTransaction(blockchain: Blockchain, network: Network, rawtx: String, closure: txIdClosure) {
        switch blockchain {
        case .bitcoin:
            BtcNetworkManager.shared.sendTransaction(network: network, rawtx: rawtx, closure: closure)
        case .ethereum:
            EthNetworkManager.shared.sendTransaction(network: network, rawtx: rawtx, closure: closure)
        }
    }
    
    func getTransactionReceipt(blockchain: Blockchain, network: Network, txid: String, closure: confirmedClosure) {
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
    
    func getUnspend(network: Network, address: String, closure: btcUtxosClosure) {
        BtcNetworkManager.shared.getUtxos(network: network, address: address, closure: closure)
    }
    
    func getEstimateFee(network: Network, closure: btcTxFeeClosure) {
        BtcNetworkManager.shared.getTxFee(network: network, closure: closure)
    }
}

// MARK: Eth

public extension NetworkManager {
    
    func getGasPrice(network: Network, closure: ethGasPriceClosure) {
        EthNetworkManager.shared.getGasPrice(network: network, closure: closure)
    }
    
    func call(network: Network, toAddress: String, data: String?, closure: ethCallClosure) {
        EthNetworkManager.shared.call(network: network, toAddress: toAddress, data: data, closure: closure)
    }
    
    func getNonce(network: Network, address: String, closure: ethNonceClosure) {
        EthNetworkManager.shared.getNonce(network: network, address: address, closure: closure)
    }
    
    func getEstimateGas(network: Network, from: String, to: String, value: String, data: String? = nil, closure: ethEstimateGasClosure) {
        EthNetworkManager.shared.getEstimateGas(network: network, from: from, to: to, value: value, data: data, closure: closure)
    }
}
