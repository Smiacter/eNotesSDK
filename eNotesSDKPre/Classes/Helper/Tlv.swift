//
//  Tlv.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/9/28.
//  Copyright © 2018 eNotes. All rights reserved.
//

/// Tag: Value typealias
public typealias Tv = [Data: Data]

final public class Tlv: NSObject {
    
    public static func generate(tag: Data, value: Data) -> Tv {
        return [tag: value]
    }
    
    /// tlv to Data, convert and add Tag, Length, Value to Data in order
    ///
    /// - Parameter:
    ///  - tlv: decode tlv info
    /// - return:
    ///  - Data: Value Data format
    public static func encode(tv: Tv) -> Data {
        var offset = 0
        var data = Data()
        for (tagData, valueData) in tv {
            data.append(tagData)
            offset += 1
            var length = valueData.count
            if length < 0xff {  // length: 2 bytes
                let lengthData = Data(bytes: &length, count: length)
                data.append(lengthData.subdata(in: 0..<1))
                offset += 1
            } else {            // length: 4 bytes
                var lengthFF = 0xff
                let lengthData1 = Data(bytes: &lengthFF, count: lengthFF)
                let lengthData2 = Data(bytes: &length, count: length)
                data.append(lengthData1.subdata(in: 0..<1))
                data.append(lengthData2.subdata(in: 0..<2))
                offset += 3
            }
            data.append(valueData)
            offset += valueData.count
        }
        
        return data
    }
    
    /// Data to tlv
    ///
    /// - Parameter:
    ///  - data: encode data
    /// - return:
    ///  - [AnyHashable: Any]: tlv info, AnyHashable is 'Tag', Any is 'Value'
    public static func decode(data: Data) -> Tv {
        var tv: Tv = [:]
        let buffer = [UInt8](data)
        let dataLength = data.count
        var parsed = 0
        while parsed < dataLength {
            let tagData = data.subdata(in: parsed..<(parsed+1))
            parsed += 1
            var length = buffer[parsed] & 0xff
            parsed += 1
            if length == 0xff {
                let lengthData = data.subdata(in: parsed..<2)
                lengthData.copyBytes(to: &length, count: Int(length))
                parsed += 2
            }
            if length > dataLength {
                continue
            }
            if (parsed + Int(length)) > dataLength {
                break
            }
            
            tv[tagData] = data.subdata(in: parsed..<(parsed+Int(length)))
            parsed += Int(length)
        }
        
        return tv
    }
}
