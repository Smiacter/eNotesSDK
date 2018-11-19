//
//  Formatter.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/9/29.
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

final public class EnoteFormatter: NSObject {
    
    /// Strip raw apdu tail data '9000'
    public static func stripApduTail(rawApdu: Data) -> Data? {
        guard rawApdu.count >= 2 else {
            return nil
        }
        return rawApdu.subdata(in: 0..<(rawApdu.count-2))
    }
    
    /// Get card's blockchain's address
    public static func address(publicKey: Data?, network: Network) -> String {
        guard let publicKey = publicKey else { return "" }
        switch network {
        case .mainnet:  // btc main blockchain
            return BTCKey(publicKey: publicKey).address.string
        case .testnet:  // btc testnet blockchain
            return BTCKey(publicKey: publicKey).addressTestnet.string
        default:
            let secureData = SecureData(data: publicKey)
            let addressData = secureData?.subdata(from: 1).keccak256().subdata(from: 12).data()
            return Address(data: addressData).checksumAddress
        }
    }
    
    /// When eth gas price value is not smallest unit, minimize it
    public static func minimizeGasPrice(gasPrice: String) -> String {
        let gasPriceNum = NSDecimalNumber(string: gasPrice)
        let unitNum = NSDecimalNumber(string: "1000000000")
        let correctGasPriceNum = gasPriceNum.multiplying(by: unitNum)
        
        return BigNumber(number: correctGasPriceNum)?.hexString ?? "0x0"
    }
    
    /// When btc fee value is not smallest unit , minimize it
    public static func minimizeFee(fee: Double) -> String {
        let valueNum = NSDecimalNumber(string: "\(fee)")
        let unitNum = NSDecimalNumber(string: "100000000")
        let smallestNum = valueNum.multiplying(by: unitNum)
        
        return BigNumber(number: smallestNum).decimalString
    }
    
    /// Packing string array to string seperate by giving character
    public static func packingArrToString(arr: [String], seperator: String = ",") -> String {
        var idStr = ""
        for id in arr{
            idStr = idStr + "\(id)\(seperator)"
        }
        if !idStr.isEmpty {
            let str = idStr.subString(to: idStr.count-1)
            idStr = str
        }
        
        return idStr
    }
}
