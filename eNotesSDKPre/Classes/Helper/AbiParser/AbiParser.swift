//
//  AbiParser.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/10/8.
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

import UIKit
import BigInt

private let abiPublicKey = "[{\"inputs\":[{\"name\":\"_mid\",\"type\":\"bytes32\"},{\"name\":\"_bid\",\"type\":\"bytes32\"}],\"name\":\"keyOf\",\"outputs\":[{\"name\":\"publickey\",\"type\":\"bytes\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
// ERC20
private let abiName = "[{\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
private let abiBalance = "[{\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
private let abiDecimals = "[{\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
private let abiSymbol = "[{\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
private let abiTransfer = "[{\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"

private enum ABI {
    case publicKey
    case name
    case balance
    case decimals
    case symbol
    case transfer
    
    var value: String {
        switch self {
        case .publicKey:
            return abiPublicKey
        case .name:
            return abiName
        case .balance:
            return abiBalance
        case .decimals:
            return abiDecimals
        case .symbol:
            return abiSymbol
        case .transfer:
            return abiTransfer
        }
    }
}

public class AbiParser: NSObject {
    
    private static func getAbiMethod(abi: ABI) -> ABIv2.Element? {
        do {
            let jsonData = abi.value.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            
            guard abiNative.count == 1 else { return nil }
            return abiNative[0]
        } catch {}
        
        return nil
    }
    
    /// encode contract input data, type is public key
    /// - parameters:
    ///  - issuer: issuer
    ///  - batch: batch
    /// - return: call input data
    public static func encodePublicKeyData(issuer: String, batch: String) -> String? {
        guard let abiMethod = getAbiMethod(abi: .publicKey) else { return nil }
        guard let issuerData = issuer.data(using: .utf8) else { return nil }
        guard let batchData = batch.data(using: .utf8) else { return nil }
        let issuerSha3Bytes = issuerData.sha3(.keccak256).bytes
        let batchSha3Bytes = batchData.sha3(.keccak256).bytes
        let parameters = [issuerSha3Bytes, batchSha3Bytes] as [AnyObject]
        
        return abiMethod.encodeParameters(parameters)?.toHexString()
    }
    
    /// decode contract return data
    /// - parameters:
    ///  - hexStr: call response hex string
    /// - return: public key
    public static func decodePublicKeyData(result: String) -> Data? {
        guard let abiMethod = getAbiMethod(abi: .publicKey) else { return nil }
        let returnData = Data(hex: result.stripHexPrefix()) //ABDHex.byteArray(fromHexString: result.stripHexPrefix())
        if let result = abiMethod.decodeReturnData(returnData), let data = result["publickey"] as? Data {
            return data
        }
        
        return nil
    }
}

// MARK: ERC20 etc.

public extension AbiParser {
    
    static func encodeNameData() -> String? {
        guard let abiMethod = getAbiMethod(abi: .name) else { return nil }
        return abiMethod.encodeParameters([AnyObject]())?.toHexString()
    }
    
    static func decodeNameData(result: String) -> String? {
        guard let abiMethod = getAbiMethod(abi: .name) else { return nil }
        let returnData = Data(hex: result.stripHexPrefix())
        if let result = abiMethod.decodeReturnData(returnData), let name = result["0"] as? String {
            return name
        }
        
        return nil
    }
    
    static func encodeBalanceData(address: String) -> String? {
        guard let abiMethod = getAbiMethod(abi: .balance) else {
            return nil
        }
        guard let ethAddress = EthereumAddress(address) else {
            return nil
        }
        
        let addr = [ethAddress] as [AnyObject]
        return abiMethod.encodeParameters(addr)?.toHexString()
        
    }
    
    static func decodeBalanceData(result: String) -> Int? {
        guard let abiMethod = getAbiMethod(abi: .balance) else { return nil }
        let returnData = Data(hex: result.stripHexPrefix())
        if let result = abiMethod.decodeReturnData(returnData), let balance = result["0"] as? BigUInt {
            return Int(balance)
        }
        
        return nil
    }
    
    static func encodeDecimalsData() -> String? {
        guard let abiMethod = getAbiMethod(abi: .decimals) else { return nil }
        return abiMethod.encodeParameters([AnyObject]())?.toHexString()
    }
    
    static func decodeDecimalsData(result: String) -> Int? {
        guard let abiMethod = getAbiMethod(abi: .decimals) else {
            return nil
        }
        let returnData = Data(hex: result.stripHexPrefix())
        if let result = abiMethod.decodeReturnData(returnData), let decimals = result["0"] as? BigUInt {
            return Int(decimals)
        }
        
        return nil
    }
    
    static func encodeSymbolData() -> String? {
        guard let abiMethod = getAbiMethod(abi: .symbol) else { return nil }
        return abiMethod.encodeParameters([AnyObject]())?.toHexString()
    }
    
    static func decodeSymbolData(result: String) -> String? {
        guard let abiMethod = getAbiMethod(abi: .symbol) else {
            return nil
        }
        let returnData = Data(hex: result.stripHexPrefix())
        if let result = abiMethod.decodeReturnData(returnData), let symbol = result["0"] as? String {
            return symbol
        }
        
        return nil
    }
    
    static func encodeTransferData(toAddress: String, value: Int?) -> Data? {
        guard let abiMethod = getAbiMethod(abi: .transfer) else {
            return nil
        }
        guard let toAddress = EthereumAddress(toAddress), let value = value else {
            return nil
        }
        let parameters = [toAddress, value] as [AnyObject]
        
        return abiMethod.encodeParameters(parameters)
    }
}
