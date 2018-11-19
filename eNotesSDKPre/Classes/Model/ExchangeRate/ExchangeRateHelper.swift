//
//  ExchangeRateHelper.swift
//  eNotes
//
//  Created by Smiacter on 2018/10/16.
//  Copyright © 2018 Smiacter. All rights reserved.
//

public enum ExchangeRateBlockchain: String {
    case btc = "BTC"
    case eth = "ETH"
    case gusd = "GUSD"
}

class ExchangeRateHelper: NSObject {
    
    static func getExchangeRateBlockchain(card: Card) -> ExchangeRateBlockchain {
        if card.blockchain == .ethereum, card.contract != nil {
            return .gusd // TODO: how to divide other ERC20 type
        }
        return card.blockchain == .bitcoin ? .btc : .eth
    }
}
