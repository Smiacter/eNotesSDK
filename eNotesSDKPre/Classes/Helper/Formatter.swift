//
//  Formatter.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/9/29.
//  Copyright © 2018 eNotes. All rights reserved.
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
}
