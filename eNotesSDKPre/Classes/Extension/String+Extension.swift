//
//  String+Extension.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/9/30.
//  Copyright © 2018 eNotes. All rights reserved.
//
import ethers

extension String {
    
    func subString(from index: Int) -> String {
        if self.count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[startIndex..<self.endIndex]
            return String(subString)
        } else {
            return self
        }
    }
    
    func subString(to index: Int) -> String {
        if self.count > index {
            let endIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[self.startIndex..<endIndex]
            return String(subString)
        } else {
            return self
        }
    }
    
    /// Return sub string position
    ///
    /// - parameters:
    ///  - subStr: sub string
    ///  - backwords: first appear if false, last appear if true
    /// - return:
    ///  - index of sub string 
    func positionOf(subStr: String, backwords: Bool = false) -> Int {
        if let range = range(of: subStr, options: backwords ? .backwards : .literal) {
            if !range.isEmpty {
                return distance(from: startIndex, to: range.lowerBound)
            }
        }
        
        return 0
    }
}

extension String {
    
    func addHexPrefix() -> String {
        if !self.hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }
    
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    func hexToStr() -> String {
        let bigNum = BigNumber(hexString: self)
        let str = bigNum?.decimalString ?? ""
        return str
    }
    
    func strToHex() -> String {
        let bigNum = BigNumber(decimalString: self)
        let hexStr = bigNum?.hexString ?? ""
        return hexStr
    }
}
