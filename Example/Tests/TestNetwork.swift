//
//  TestNetwork.swift
//  eNotesSDK_Tests
//
//  Created by Smiacter on 2018/10/11.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import eNotesSDKPre

let testnetAddress = "mgdR9PLSDVCmfVs3xyJwkkDkMbNfsekgE7"
let testnetAddress2 = "mtXWDB6k5yC5v7TcwKZHB89SUp85yCKshy"
let kovanAddress = "0xE2e41374805d62fA2F5005479513fEbCD2B1c31B"
let kovanToAddress = "0x5C036d8490127ED26E3A142024082eaEE482BbA2"
let kovanTokenAddress = "0x4013F07264c31A4B0303B05eA5a6eBD08dC919a0"
let kovanTokenContract = "0x0F57219668B6B82f2a846fc84BBD2c7D4ceA3B1b"

class TestNetwork: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: Universal
    
    func testGetBalance() {
        let expectate = expectation(description: "eth gas price requst")
        let timeout: TimeInterval = 5
        NetworkManager.shared.getBalance(blockchain: .bitcoin, network: .testnet, address: testnetAddress) { (balance, error) in
            expectate.fulfill()
            XCTAssert(error == nil)
        }
        wait(for: [expectate], timeout: timeout)
    }
    
    func testGetMultBalances() {
        let expectate = expectation(description: "eth gas price requst")
        let timeout: TimeInterval = 5
        NetworkManager.shared.getMultBalances(blockchain: .bitcoin, network: .testnet, addresses: [testnetAddress, testnetAddress2]) { (balances, error) in
            expectate.fulfill()
            XCTAssert(error == nil)
            XCTAssert(balances != nil)
        }
        wait(for: [expectate], timeout: timeout)
    }
    
    func testGetBtcTestnetTxs() {
        let expectate = expectation(description: "eth gas price requst")
        let timeout: TimeInterval = 5
        NetworkManager.shared.getTransactionHistory(blockchain: .bitcoin, network: .testnet, address: testnetAddress, contract: nil) { (txs, error) in
            expectate.fulfill()
            XCTAssert(error == nil)
            XCTAssert(txs != nil)
            print(txs!.count)
        }
        wait(for: [expectate], timeout: timeout)
    }
    
    func testGetEthKovanTxs() {
        let expectate = expectation(description: "eth gas price requst")
        let timeout: TimeInterval = 5
        NetworkManager.shared.getTransactionHistory(blockchain: .ethereum, network: .kovan, address: kovanAddress, contract: nil) { (txs, error) in
            expectate.fulfill()
            XCTAssert(error == nil)
            XCTAssert(txs != nil)
        }
        wait(for: [expectate], timeout: timeout)
    }
    
    func testGetEthKovanTokenTxs() {
        let expectate = expectation(description: "eth gas price requst")
        let timeout: TimeInterval = 5
        NetworkManager.shared.getTransactionHistory(blockchain: .ethereum, network: .kovan, address: kovanTokenAddress, contract: kovanTokenContract) { (txs, error) in
            expectate.fulfill()
            XCTAssert(error == nil)
            XCTAssert(txs != nil)
        }
        wait(for: [expectate], timeout: timeout)
    }
    
    func testGetExchangeRate() {
        let expectate = expectation(description: "eth gas price requst")
        let timeout: TimeInterval = 5
        NetworkManager.shared.getExchangeRate(blockchain: .bitcoin, isToken: false) { (rates, apiType, error) in
            expectate.fulfill()
            XCTAssert(error == nil)
            XCTAssert(rates != nil)
        }
        wait(for: [expectate], timeout: timeout)
    }
    
    // MARK: Eth
    
    func testGetEthGasPrice() {
        let expectate = expectation(description: "eth gas price requst")
        let timeout: TimeInterval = 5
        NetworkManager.shared.getGasPrice(network: .kovan) { (gas, model, error) in
            expectate.fulfill()
            XCTAssert(error == nil)
            XCTAssert(gas != "0x0")
            XCTAssert(model != nil)
        }
        wait(for: [expectate], timeout: timeout)
    }
    
    func testEthCall() {
        let expectate = expectation(description: "eth call request")
        let timeout: TimeInterval = 5
        NetworkManager.shared.call(network: .kovan, toAddress: "0x5C036d8490127ED26E3A142024082eaEE482BbA2", data: "95c6fa61f319d9523579074cf82dd04de07d42fa5dede2ddccd53713da7d06a44f1a87be0e2c9aa962262100508a2a2ff6665bcd9d731eea5bb62d15caed02c55da9991b") { (result, error) in
            expectate.fulfill()
            let decodeString = AbiParser.decodePublicKeyData(result: result)?.toHexString() ?? ""
            XCTAssert(error == nil)
            XCTAssert(decodeString == "0234d246477bed155522be2f18e31e9dd7bbcbdf3e4d33a70aae1a7d72106971ff")
        }
        wait(for: [expectate], timeout: timeout)
    }
    
    func testGetEthNonce() {
        let expectate = expectation(description: "eth gas price requst")
        let timeout: TimeInterval = 5
        NetworkManager.shared.getNonce(network: .kovan, address: "0xE2e41374805d62fA2F5005479513fEbCD2B1c31B") { (nonce, error) in
            expectate.fulfill()
            XCTAssert(error == nil)
        }
        wait(for: [expectate], timeout: timeout)
    }
    
    // TODO:
    func testGetEstimateGas() {
        let expectate = expectation(description: "eth gas price requst")
        let timeout: TimeInterval = 5
        NetworkManager.shared.getEstimateGas(network: .kovan, from: kovanAddress, to: kovanToAddress, value: "1000000000", data: nil) { (gas, error) in
            expectate.fulfill()
            XCTAssert(error == nil)
        }
        wait(for: [expectate], timeout: timeout)
    }
    
    // MARK: Btc

    func testGetUnspend() {
        let expectate = expectation(description: "eth gas price requst")
        let timeout: TimeInterval = 5
        NetworkManager.shared.getUnspend(network: .testnet, address: "mgdR9PLSDVCmfVs3xyJwkkDkMbNfsekgE7") { (unspends, error) in
            expectate.fulfill()
            XCTAssert(error == nil)
            XCTAssert(unspends.count >= 0)
        }
        wait(for: [expectate], timeout: timeout)
    }
    
    func testGesEstimateFee() {
        let expectate = expectation(description: "eth gas price requst")
        let timeout: TimeInterval = 5
        NetworkManager.shared.getEstimateFee(network: .testnet) { (fee, feeModel, error) in
            expectate.fulfill()
            XCTAssert(error == nil)
            XCTAssert(fee > 0)
            XCTAssert(feeModel != nil)
        }
        wait(for: [expectate], timeout: timeout)
    }
}
