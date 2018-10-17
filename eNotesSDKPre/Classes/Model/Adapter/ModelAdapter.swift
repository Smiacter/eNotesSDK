//
//  ModelAdapter.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/14.
//  Copyright © 2018 Smiacter. All rights reserved.
//
import ethers

extension Decodable {
    
    /// return: hex string type
    func toGasPrice() -> String {
        if let model = self as? EtherchainGasPrice {
            return EnoteFormatter.minimizeGasPrice(gasPrice: model.fast)
        } else if let model = self as? InfuraGasPrice {
            return model.result
        } else if let model = self as? eNotesGasPriceRaw {
            return model.data.price
        }
        
        return "0x0"
    }
    
    func toNonce() -> UInt {
        if let model = self as? InfuraGasPrice {
            return UInt(BigNumber(hexString: model.result).integerValue)
        } else if let model = self as? eNotesNonceRaw {
            return UInt(BigNumber(hexString: model.data.nonce).integerValue)
        }
        
        return 0
    }
    
    /// return: hex string type
    func toEstimateGas() -> String {
        if let model = self as? InfuraGasPrice {
            return model.result
        } else if let model = self as? eNotesEstimateGasRaw {
            return model.data.gas
        }
        
        return "0x0"
    }
    
    /// return hex string value
    func toBalance() -> String {
        if let model = self as? InfuraGasPrice {
            return model.result
        } else if let model = self as? EtherscanBalance {
            return model.result.strToHex() // convert normal string to hex string
        } else if let model = self as? BlockchainBalance {
            return "\(model.final_balance)".strToHex()
        } else if let model = self as? BlockcypherBalance {
            return "\(model.balance)".strToHex()
        } else if let model = self as? BlockexplorerBalance {
            return "\(model.balanceSat)".strToHex()
        } else if let model = self as? [eNotesBalanceRaw] {
            guard model.count == 1, let balance = model[0].data.balance else {
                return ""
            }
            return balance
        }
        
        return ""
    }
    
    func toTxId() -> String {
        if let model = self as? InfuraGasPrice {
            return model.result
        } else if let model = self as? BlockexplorerTxid {
            return model.txid
        } else if let model = self as? BlockcypherTxidRaw {
            return model.tx.hash
        } else if let model = self as? [eNotesTxidRaw] {
            guard model.count == 1, let txid = model[0].data.txid else {
                return ""
            }
            return txid
        }
        
        return ""
    }
    
    func toConfirmStatus() -> ConfirmStatus {
        if let model = self as? InfuraTxReceiptRaw {
            if model.result == nil {
                return .confirming
            }
            return model.result!.status.hexToStr() == "1" ? .confirmed : .confirming
        } else if let model = self as? BlockexplorerTxReceipt {
            return model.confirmations > 0 ? .confirmed : .confirming
        } else if let model = self as? [eNotesTxReceiptRaw] {
            guard model.count == 1, let status = model[0].data.confirmations else {
                return .confirming
            }
            return status.hexToStr() != "0" ? .confirmed : .confirming
        }
        
        return .none
    }
    
    func toUtxos() -> [UtxoModel] {
        if let model = self as? BlockchainUtxosRaw {
            return model.toUtxoModels()
        } else if let model = self as? BlockcypherUtxosRaw {
            return model.toUtxoModels()
        } else if let model = self as? [BlockexplorerUtxos] {
            return model.map { return $0.toUtxoModel() }
        } else if let model = self as? eNotesUtxosRaw {
            return model.toUtxoModels()
        }
        
        return []
    }
    
    /// Int64-BTCAmount
    func toBtcTxFee() -> Int64 {
        if let model = self as? BlockcypherFee {
            return Int64(model.medium_fee_per_kb)
        } else if let model = self as? BitcoinFees {
            return Int64(model.halfHourFee) * 1000
        } else if let model = self as? BlockexplorerFee {
            if let satoshiFee = Int(EnoteFormatter.minimizeFee(fee: model.fee)) {
                return Int64(satoshiFee)
            }
            return 0
        } else if let model = self as? eNotesEstimateFeeRaw {
            return Int64(model.data.feerate.hexToStr()) ?? 0
        }
        
        return 0
    }
}
