//
//  Verification.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/9/30.
//  Copyright © 2018 eNotes. All rights reserved.
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
