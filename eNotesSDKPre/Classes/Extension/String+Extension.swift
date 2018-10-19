//
//  String+Extension.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/9/30.
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
