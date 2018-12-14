//
//  NetworkDefinition.swift
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

let enableEnotesApi = true

/// timeout for request
let timeoutForRequest: TimeInterval = 5
typealias RequestTuple = (apiType: ApiType, isHandled: Bool)
typealias EthRequestOrder = [RequestTuple]
/// defualt eth api request order except gas price
let DefaultEthApiOrder: [ApiType] = enableEnotesApi ? [.infura, .etherscan, .eNotes] : [.infura, .etherscan]
/// default eth gas price request order
let DefaultGasPriceApiOrder: [ApiType] = enableEnotesApi ? [.etherchain, .infura, .etherscan, .eNotes] :  [.etherchain, .infura, .etherscan]

/// default btc get fee api order - mainet
let DefaultBtcFeeApiOrder: [ApiType] = enableEnotesApi ? [.blockcypher, .bitcoinfees, .blockexplorer, .eNotes] : [.blockcypher, .bitcoinfees, .blockexplorer]
let DefaultBtcFeeTestApiOrder: [ApiType] = enableEnotesApi ? [.blockcypher, .blockexplorer, .eNotes] :  [.blockcypher, .blockexplorer]
let DefaultBtcTxsApiOrder: [ApiType] = [.blockexplorer, .blockcypher]
/// common btc api array
let BtcCommonApis: [ApiType] = enableEnotesApi ?  [.blockchain, .blockcypher, .blockexplorer, .eNotes] : [.blockchain, .blockcypher, .blockexplorer]
/// send transaction btc api array
let BtcSendTxApis: [ApiType] = enableEnotesApi ?  [.blockcypher, .blockexplorer, .eNotes] : [.blockcypher, .blockexplorer]

/// api keys - etherscan
let EtherscanApiKeys = ["JVSWRAFRJZ5I5ANGHS3SVHTP1FRFP67A4J",
                        "GVZVPSQHD6AY15MIJXJFRY4AW82AT7Z1UG",
                        "X9QCCGJS9PN331TSRE368Y6EG5EAZ3PN8M"]
/// api keys - infura
let InfuraApiKeys = ["1a3b1601f246404b9578a0d1be70e6f3",
                     "4913275e9b8f45fb8c8e5870c7c91bf7",
                     "11bf57adbfc943228151de57fc441b8b",
                     "7ddb525a0d2a48ee86fcb6776a50104f",
                     "939218ad17d849ef8ed82fec270d41c1"]
/// api keys - blockcypher
let BlockcypherApiKeys = ["e967dba1620441c8ab57d48e88150d87",
                          "ce05502a8ab447db8f3e7dbf10e830cd",
                          "db5dad2ee7d5496184d78a2a0012246a",
                          "21a6d79adca247808a06b6f899a99577",
                          "ab673cc2aeae4a1b81bc6fa38363b2b6"]
/// eth call to address
let EthCallToAddress = "0x9A21e2c918026D9420DdDb2357C8205216AdD269"
let EthCallTestToAddress = "0x5C036d8490127ED26E3A142024082eaEE482BbA2"
let EthCallTestPrefix = "test-"
let EthCallDemoPrefix = "demo-"
/// jsonrpc version
let JsonRpcVersion = "2.0"
/// infura post param: id
let InfuraId = 1

// exchange rate request api order
let DefaultRateApiOrder: [RateApi] = [.coinbase, .bitz, .cryptocompare, .okex] // for eth and btc
let GusdRateApiOrder: [RateApi] = [.cryptocompare, .okex] // for gusd
let Usd2OtherApiOrder: [RateApi] = [.bitz, .cryptocompare] // get other currency price per usd

public enum ApiType {
    // eth
    case infura
    case etherscan
    case etherchain
    // btc
    case blockchain
    case blockcypher
    case blockexplorer
    case bitcoinfees
    // eNotes
    case eNotes
}

/// card type, we support btc and eth for now
public enum Blockchain: Int {
    case bitcoin
    case ethereum
    
    // eNotes request use string type
    var eNotesString: String {
        switch self {
        case .bitcoin:
            return "bitcoin"
        case .ethereum:
            return "ethereum"
        }
    }
    
    /// short value
    public var short: String {
        switch self {
        case .bitcoin:
            return "BTC"
        default:
            return "ETH"
        }
    }
}

public enum Network: Int {
    case mainnet
    case testnet
    case ethereum
    case kovan
    case ropsten
    case rinkeby
    
    public var isBitcoin: Bool {
        switch self {
        case .mainnet, .testnet:
            return true
        default:
            return false
        }
    }
    
    // eNotes request use string type
    var eNotesString: String {
        switch self {
        case .mainnet, .ethereum:
            return "mainnet"
        case .testnet:
            return "testnet"
        case .kovan:
            return "kovan"
        case .ropsten:
            return "ropsten"
        case .rinkeby:
            return "rinkeby"
        }
    }
    
    func network(api: ApiType) -> String {
        switch self {
        case .mainnet:
            return mainnetNetwork(api: api)
        case .testnet:
            return testnetNetwork(api: api)
        case .ethereum:
            return ethereumNetwork(api: api)
        case .kovan:
            return kovanNetwork(api: api)
        case .ropsten:
            return ropstenNetwork(api: api)
        case .rinkeby:
            return rinkebyNetwork(api: api)
        }
    }
    
    // main - btc only
    private func mainnetNetwork(api: ApiType) -> String {
        switch api {
        case .blockchain:
            return ""
        case .blockcypher:
            return "main"
        case .blockexplorer:
            return ""
        case .bitcoinfees:
            return ""
        case .infura, .etherscan, .etherchain:
            return ""
        case .eNotes:
            return "mainnet"
        }
    }
    
    // test - btc only
    private func testnetNetwork(api: ApiType) -> String {
        switch api {
        case .blockchain:
            return "testnet."
        case .blockcypher:
            return "test3"
        case .blockexplorer:
            return "testnet."
        case .bitcoinfees:
            return ""
        case .infura, .etherscan, .etherchain:
            return ""
        case .eNotes:
            return "testnet"
        }
    }
    
    // eth only
    private func ethereumNetwork(api: ApiType) -> String {
        switch api {
        case .infura:
            return "mainnet"
        case .etherscan:
            return "api"
        case .etherchain:       // no need network string
            return ""
        case .blockchain, .blockcypher, .blockexplorer, .bitcoinfees:
            return ""
        case .eNotes:
            return "mainnet"
        }
    }
    
    // eth only
    private func kovanNetwork(api: ApiType) -> String {
        switch api {
        case .infura:
            return "kovan"
        case .etherscan:
            return "kovan"
        case .etherchain:       // no need network string
            return ""
        case .blockchain, .blockcypher, .blockexplorer, .bitcoinfees:
            return ""
        case .eNotes:
            return "kovan"
        }
    }
    
    // eth only
    private func ropstenNetwork(api: ApiType) -> String {
        switch api {
        case .infura:
            return "ropsten"
        case .etherscan:
            return "api-ropsten"
        case .etherchain:       // no need network string
            return ""
        case .blockchain, .blockcypher, .blockexplorer, .bitcoinfees:
            return ""
        case .eNotes:
            return "ropsten"
        }
    }
    
    // eth only
    private func rinkebyNetwork(api: ApiType) -> String {
        switch api {
        case .infura:
            return "rinkeby"
        case .etherscan:
            return "api-rinkeby"
        case .etherchain:       // no need network string
            return ""
        case .blockchain, .blockcypher, .blockexplorer, .bitcoinfees:
            return ""
        case .eNotes:
            return "rinkeby"
        }
    }
    
    // eth only
    var contractAddress: String {
        switch self {
        case .kovan:
            return EthCallTestToAddress
        case .ethereum:
            return EthCallToAddress
        default:
            fatalError("unsupport type")
        }
    }
}

public enum RateApi {
    case coinbase
    case okex
    case bitz
    case cryptocompare
}
