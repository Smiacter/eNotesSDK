//
//  Random.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/9/28.
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

import Foundation
import CommonCrypto
import Security

/// A generic random bytes generators.

public protocol Random {
    
    /// Generates the specified number of random bytes and throws an error in case of failure.
    ///
    /// - parameter bytes: The number of bytes to generate.
    /// - throws: If generation fails, throws a `CryptoError` object.
    /// - returns: A Data buffer filled with the random bytes.
    static func generate(bytes: Int) throws -> Data
    
}

///The CommonCrypto random bytes generator.

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

/// The Security.framework random bytes generator.

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
