//
//  Verification.swift
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

final public class Verification: NSObject {

    public static func verify(r: String, s: String, org: String, publicKey: String) -> Bool {
        var r = r, s = s
        if r.count == 66 {
            r = r.subString(from: 2)
        }
        if s.count == 66 {
            s = s.subString(from: 2)
        }
        r = r.lowercased()
        s = s.lowercased()
        
        guard let bigR = BTCBigNumber(hexString: r), let bigS = BTCBigNumber(hexString: s) else {
            return false
        }
        let unsafeR = unsafeBitCast(bigR.bignum, to: UnsafeMutablePointer<BIGNUM>.self)
        let unsafeS = unsafeBitCast(bigS.bignum, to: UnsafeMutablePointer<BIGNUM>.self)
        var sig = ECDSA_SIG(r: unsafeR, s: unsafeS)
        
        let publicKeyData = Data(hex: publicKey)
        let orgData = Data(hex: org)
        let key = BTCKey(publicKey: publicKeyData)
        let hash = SecureData.sha256(SecureData.sha256(orgData))
        let result = key?.isValidSig(&sig, hash: hash)
        
        return result ?? false
    }
}
