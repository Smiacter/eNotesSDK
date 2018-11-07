//
//  Formatter.swift
//  eNotesSDKTest
//
//  Created by Smiacter on 2018/10/18.
//  Copyright © 2018 eNotes. All rights reserved.
//

import UIKit
import eNotesSDKPre

extension BTCAmount {
    
    func formatBtcFee(utxoCount: Int) -> BTCAmount {
        return BTCAmount(148 * utxoCount + 44) * self / 1000
    }
}

extension Network {
    
    func toString() -> String {
        switch self {
        case .mainnet:
            return "mainnet"
        case .testnet:
            return "testnet"
        case .ethereum:
            return "ethereum"
        case .kovan:
            return "kovan"
        case .ropsten:
            return "ropsten"
        case .rinkeby:
            return "rinkeby"
        }
    }
}
