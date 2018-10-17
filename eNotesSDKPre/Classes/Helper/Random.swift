//
//  Random.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/9/28.
//  Copyright © 2018 eNotes. All rights reserved.
//

import Foundation
import CommonCrypto
import Security

/**
 * A generic random bytes generators.
 */

public protocol Random {
    
    /**
     * Generates the specified number of random bytes and throws an error in case of failure.
     *
     * - parameter bytes: The number of bytes to generate.
     * - throws: If generation fails, throws a `CryptoError` object.
     * - returns: A Data buffer filled with the random bytes.
     */
    
    static func generate(bytes: Int) throws -> Data
    
}

/**
 * The CommonCrypto random bytes generator.
 */

public enum CommonRandom: Random {
    
    public static func generate(bytes: Int) throws -> Data {
        
        var buffer = Data(count: bytes)
        
        try buffer.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<UInt8>) in
            
            let status = CCRandomGenerateBytes(UnsafeMutableRawPointer(ptr), bytes)
            
            if let error = CryptoError(status: status) {
                throw error
            }
            
        }
        
        return buffer
        
    }
    
}

/**
 * The Security.framework random bytes generator.
 */

public enum SecRandom: Random {
    
    public static func generate(bytes: Int) throws -> Data {
        
        var buffer = Data(count: bytes)
        
        try buffer.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<UInt8>) in
            
            let status = SecRandomCopyBytes(kSecRandomDefault, bytes, UnsafeMutableRawPointer(ptr))
            
            guard status == errSecSuccess else {
                throw CryptoError.unknownStatus(status)
            }
            
        }
        
        return buffer
        
    }
    
}


public enum CryptoError: Error {
    
    case illegalParameter
    case bufferTooSmall
    case memoryFailure
    case alignmentError
    case decodeError
    case overflow
    case rngFailure
    case callSequenceError
    case keySizeError
    case unimplemented
    case unspecifiedError
    case unknownError(CCStatus)
    case unknownStatus(OSStatus)
    
    init?(status: CCStatus) {
        
        let intStatus = Int(status)
        
        switch intStatus {
        case kCCSuccess: return nil
        case kCCParamError: self = .illegalParameter
        case kCCBufferTooSmall: self = .bufferTooSmall
        case kCCMemoryFailure: self = .memoryFailure
        case kCCAlignmentError: self = .alignmentError
        case kCCDecodeError: self = .decodeError
        case kCCOverflow: self = .overflow
        case kCCRNGFailure: self = .rngFailure
        case kCCCallSequenceError: self = .callSequenceError
        case kCCKeySizeError: self = .keySizeError
        case kCCUnimplemented: self = .unimplemented
        case kCCUnspecifiedError: self = .unspecifiedError
        default: self = .unknownError(status)
        }
        
    }
    
}

// MARK: - Equatable
extension CryptoError: Equatable {
    
    public static func == (lhs: CryptoError, rhs: CryptoError) -> Bool {
        
        switch (lhs, rhs) {
        case (.illegalParameter, .illegalParameter): return true
        case (.bufferTooSmall, .bufferTooSmall): return true
        case (.memoryFailure, .memoryFailure): return true
        case (.alignmentError, .alignmentError): return true
        case (.decodeError, .decodeError): return true
        case (.overflow, .overflow): return true
        case (.rngFailure, .rngFailure): return true
        case (.callSequenceError, .callSequenceError): return true
        case (.keySizeError, .keySizeError): return true
        case (.unimplemented, .unimplemented): return true
        case (.unspecifiedError, .unspecifiedError): return true
        case (.unknownError(let lStatus), .unknownError(let rStatus)): return lStatus == rStatus
        case (.unknownStatus(let lStatus), .unknownStatus(let rStatus)): return lStatus == rStatus
        default: return false
        }
        
    }
    
}
//final public class Random {
//
//    public static func generateString(count: Int) -> String {
//        let a = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
//
//        var s = ""
//
//        for _ in 0..<count
//        {
//            let r = Int(arc4random_uniform(UInt32(a.count)))
//
//            s += String(a[a.index(a.startIndex, offsetBy: r)])
//        }
//
//        return s
//    }
//}
