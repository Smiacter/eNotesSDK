//
//  Card.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/16.
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
    public var isFrozen: Bool?
    // ERC20 token info
    public var name: String?
    public var symbol: String?
    public var decimals = 0
    
    public init() {}
}
