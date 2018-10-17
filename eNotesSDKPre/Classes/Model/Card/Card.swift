//
//  Card.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/16.
//  Copyright © 2018 Smiacter. All rights reserved.
//
//  desc: read card info

public struct Card {
    // readed card info by asn1 decoder
    public var tbsCertificateAndSig = Data()
    public var tbsCertificate = Data()
    public var issuer = ""
    public var issueTime = Date()
    public var deno = 0
    public var blockchain: Blockchain = .bitcoin
    public var network: Network = .testnet
    public var contract: String?
    public var publicKey = ""
    public var serialNumber = ""
    public var manufactureBatch = ""
    public var manufactureTime = Date()
    public var r = ""
    public var s = ""
    // custom info
    public var address = ""
    public var isSafe = true
    public var publicKeyData: Data?
    // ERC20 token info
    public var name: String?
    public var symbol: String?
    public var decimals = 0
}
