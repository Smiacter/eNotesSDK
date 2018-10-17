//
//  CertificateParser.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/10/8.
//  Copyright © 2018 eNotes. All rights reserved.
//

import UIKit

class CertificateParser: NSObject {

    private var decoder: X509Certificate?
    private var tbsCertificateAndSig :Data!
    private var tbsCertificate :Data!
    private var version: Int = -1
    private var r = ""
    private var s = ""
    /// vendorName
    private var issuer = ""
    /// productionDate
    private var issueTime = Date()
    /// face value
    private var deno: Int = -1
    /// cornType, btc:80000000 eth:8000003c
    private var blockchain = ""
    /// network, MainBtc:0 TestBtc:1 Ethereum:1 EthereumRopsten:3 EthereumRinkeby:4 EthereumKovan:42
    private var network: Int = -1
    private var contract: String?
    private var publicKeyInformation = ""
    private var serialNumber = ""
    private var manufactureBatch = ""
    private var manufactureTime = Date()
    
    init?(hexCert: String) {
        guard let data = Data(base64Encoded: hexCert) else {
            return nil
        }
        do {
            try decoder = X509Certificate(data: data)
            guard decoder != nil else {
                return
            }
            tbsCertificateAndSig=decoder!.tbsCertificateData
            tbsCertificate=decoder!.tbsCertificate.rawValue
            version = decoder!.version
            issuer = decoder!.issuer
            issueTime = decoder!.issueTime
            deno = decoder!.deno
            blockchain = decoder!.blockchain
            network = decoder!.network
            contract = decoder!.contract
            publicKeyInformation = decoder!.publicKeyInformation
            serialNumber = decoder!.serialNumber
            manufactureBatch = decoder!.manufactureBatch
            manufactureTime = decoder!.manufactureTime
            r = decoder!.r
            s = decoder!.s
        } catch  {
            return nil //print("decoder init fail")
        }
    }
    
    func toCard() -> Card {
        var card = Card()
        card.tbsCertificateAndSig = tbsCertificateAndSig
        card.tbsCertificate = tbsCertificate
        card.issuer = issuer
        card.issueTime = issueTime
        card.deno = deno
        card.blockchain = blockchain == "80000000" ? .bitcoin : .ethereum
        card.network = toNetwork()
        card.contract = contract
        if let contract = contract, contract.isEmpty {
            card.contract = nil
        }
        card.publicKey = publicKeyInformation
        card.serialNumber = serialNumber
        card.manufactureBatch = manufactureBatch
        card.manufactureTime = manufactureTime
        card.r = r
        card.s = s
        
        return card
    }
    
    /// convert to 'Network'
    private func toNetwork() -> Network {
        if blockchain == "80000000" {
            switch network {
            case 0:
                return .mainnet
            default:            // network == 1
                return .testnet
            }
        } else {
            switch network {
            case 1:
                return .ethereum
            case 3:
                return .ropsten
            case 4:
                return .rinkeby
            default:            // network == 42
                return .kovan
            }
        }
    }
}
