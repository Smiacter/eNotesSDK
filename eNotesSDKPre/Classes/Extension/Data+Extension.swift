//
//  Data+Extension.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/9/28.
//  Copyright © 2018 eNotes. All rights reserved.
//

extension Data {
    
    public func subdata(in range: CountableClosedRange<Data.Index>) -> Data
    {
        return self.subdata(in: range.lowerBound..<range.upperBound + 1)
    }
}

extension Data {
    
    public init(hex: String) {
        self.init(bytes: Array<UInt8>(hex: hex))
    }
    
    public var bytes: Array<UInt8> {
        return Array(self)
    }
    
//    public func toHexString() -> String {
//        return bytes.toHexString()
//    }
}

extension Data {
    
    public func toBase64String() -> String {
        return self.base64EncodedString(options: .endLineWithLineFeed)
    }
}
