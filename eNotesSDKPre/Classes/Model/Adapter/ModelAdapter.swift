//
//  ModelAdapter.swift
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
    func toMultBalance() -> [MultiBalance]? {
        if let model = self as? EtherscanMultBalanceRaw {
            return model.result.map { return MultiBalance(address: $0.account, balance: $0.balance.strToHex()) }
        } else if let model = self as? BlockchainMultBalanceRaw {
            return model.addresses.map { return MultiBalance(address: $0.address, balance: BigNumber(integer: $0.final_balance)?.hexString ?? "0x0") }
        }
        
        return nil
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
    
    func toTransactionHistory(address: String) -> [TransactionHistory] {
        if let model = self as? BlockexplorerTxsRaw {
            return model.items.map { tx in
                var th = TransactionHistory()
                th.isSender = tx.vin.contains(where: { $0.addr == address })
                th.time = tx.time
                th.txid = tx.txid
                th.confirmations = tx.confirmations
                th.value = th.isSender ? Int64(tx.valueIn * 100000000) : Int64(tx.valueOut * 100000000)
                return th
            }
        } else if let model = self as? BlockcypherTxsRaw {
            return model.txrefs.map({ tx in
                var th = TransactionHistory()
                th.time = tx.formatTime()
                th.txid = tx.tx_hash
                th.confirmations = tx.confirmations
                th.value = tx.value
                th.isSender = tx.spent == nil
                return th
            })
        } else if let model = self as? EtherscanTxsRaw {
            return model.result.map({ tx in
                var th = TransactionHistory()
                th.time = TimeInterval(tx.timeStamp) ?? 0
                th.txid = tx.hash
                th.confirmations = Int(tx.confirmations) ?? 0
                th.value = Int64(tx.value) ?? 0
                th.isSender = tx.from.lowercased() == address.lowercased()
                return th
            })
        }
        
        return []
    }
}

// MARK: Exchange Rate

extension Decodable {
    
    func toExchangeRate() -> ExchangeRate? {
        if let model = self as? CoinbaseRaw {
            return ExchangeRate(btc: Double(model.data.rates.BTC) ?? 0,
                                eth: Double(model.data.rates.ETH) ?? 0,
                                gusd: nil,
                                usd: Double(model.data.rates.USD) ?? 0,
                                cny: Double(model.data.rates.CNY) ?? 0,
                                eur: Double(model.data.rates.EUR) ?? 0,
                                jpy: Double(model.data.rates.JPY) ?? 0)
        } else if let model = self as? BitzRaw {
            var rates: BitzRates?
            if model.data.btc != nil {
                rates = model.data.btc
            } else if model.data.eth != nil {
                rates = model.data.eth
            }
            guard let rate = rates else { return nil }
        
            return ExchangeRate(btc: Double(rate.btc) ?? 0,
                                eth: Double(rate.eth) ?? 0,
                                gusd: nil,
                                usd: Double(rate.usd) ?? 0,
                                cny: Double(rate.cny) ?? 0,
                                eur: Double(rate.eur) ?? 0,
                                jpy: Double(rate.jpy) ?? 0)
        } else if let model = self as? CryptoCompare {
            var rates: CryptoCompareRates?
            if model.BTC != nil {
                rates = model.BTC
            } else if model.ETH != nil {
                rates = model.ETH
            } else if model.GUSD != nil  {
                rates = model.GUSD
            }
            guard let rate = rates else { return nil }
            
            return ExchangeRate(btc: rate.BTC ?? 0,
                                eth: rate.ETH ?? 0,
                                gusd: rate.GUSD ?? 0,
                                usd: rate.USD ?? 0,
                                cny: rate.CNY ?? 0,
                                eur: rate.EUR ?? 0,
                                jpy: rate.JPY ?? 0)
        }
        
        return nil
    }
    
    func toUsd2Other() -> Usd2OtherCurrency? {
        if let model = self as? BitzRaw, let ethRate = model.data.eth,
            let usd = Double(ethRate.usd), let cny = Double(ethRate.cny),
            let eur = Double(ethRate.eur), let jpy = Double(ethRate.jpy), usd != 0 {
            
            let usd2cny = cny / usd
            let usd2eur = eur / usd
            let usd2jpy = jpy / usd
            return Usd2OtherCurrency(usd2cny: usd2cny, usd2eur: usd2eur, usd2jpy: usd2jpy)
            
        } else if let model = self as? CryptoCompare, let ethRate = model.ETH, let usd = ethRate.USD, usd != 0 {
            let usd2cny = ethRate.CNY ?? 0 / usd
            let usd2eur = ethRate.EUR ?? 0 / usd
            let usd2jpy = ethRate.JPY ?? 0 / usd
            return Usd2OtherCurrency(usd2cny: usd2cny, usd2eur: usd2eur, usd2jpy: usd2jpy)
        }
        
        return nil
    }
}
