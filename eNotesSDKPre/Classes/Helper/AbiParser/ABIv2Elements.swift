//
//  ABIElements.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

// MARK: definition

extension ABIv2 {
    // JSON Decoding
    public struct Input: Decodable {
        var name: String?
        var type: String
        var indexed: Bool?
        var components: [Input]?
    }
    
    public struct Output: Decodable {
        var name: String?
        var type: String
        var components: [Output]?
    }

    public struct Record: Decodable {
        var name: String?
        var type: String?
        var payable: Bool?
        var constant: Bool?
        var stateMutability: String?
        var inputs: [ABIv2.Input]?
        var outputs: [ABIv2.Output]?
        var anonymous: Bool?
    }
    
    public enum Element {
        public enum ArraySize { //bytes for convenience
            case staticSize(UInt64)
            case dynamicSize
            case notArray
        }
        
        case function(Function)
        case constructor(Constructor)
        case fallback(Fallback)
        case event(Event)
        
        public struct InOut {
            let name: String
            let type: ParameterType
        }
        
        public struct Function {
            let name: String?
            let inputs: [InOut]
            let outputs: [InOut]
            let constant: Bool
            let payable: Bool
        }
        
        public struct Constructor {
            let inputs: [InOut]
            let constant: Bool
            let payable: Bool
        }
        
        public struct Fallback {
            let constant: Bool
            let payable: Bool
        }
        
        public struct Event {
            let name: String
            let inputs: [Input]
            let anonymous: Bool
            
            struct Input {
                let name: String
                let type: ParameterType
                let indexed: Bool
            }
        }
    }
    
    public enum ParsingError: Error {
        case invalidJsonFile
        case elementTypeInvalid
        case elementNameInvalid
        case functionInputInvalid
        case functionOutputInvalid
        case eventInputInvalid
        case parameterTypeInvalid
        case parameterTypeNotFound
        case abiInvalid
    }
    
    enum TypeParsingExpressions {
        static var typeEatingRegex = "^((u?int|bytes)([1-9][0-9]*)|(address|bool|string|tuple|bytes)|(\\[([1-9][0-9]*)\\]))"
        static var arrayEatingRegex = "^(\\[([1-9][0-9]*)?\\])?.*$"
    }
    
    enum ElementType: String {
        // only support function now
        case function
//        case constructor
//        case fallback
    }
}

// MARK: helper - parsing

extension ABIv2.Record {
    
    public func parse() throws -> ABIv2.Element {
        let typeString = self.type != nil ? self.type! : "function"
        guard let type = ABIv2.ElementType(rawValue: typeString) else {
            throw ABIv2.ParsingError.elementTypeInvalid
        }
        return try parseToElement(from: self, type: type)
    }
}

fileprivate func parseToElement(from abiRecord: ABIv2.Record, type: ABIv2.ElementType) throws -> ABIv2.Element {
    switch type {
    case .function:
        let function = try parseFunction(abiRecord: abiRecord)
        return ABIv2.Element.function(function)
//    case .constructor:
//        let constructor = try parseConstructor(abiRecord: abiRecord)
//        return ABIv2.Element.constructor(constructor)
//    case .fallback:
//        let fallback = try parseFallback(abiRecord: abiRecord)
//        return ABIv2.Element.fallback(fallback)
    }
    
}

fileprivate func parseFunction(abiRecord:ABIv2.Record) throws -> ABIv2.Element.Function {
    let inputs = try abiRecord.inputs?.map({ (input:ABIv2.Input) throws -> ABIv2.Element.InOut in
        let nativeInput = try input.parse()
        return nativeInput
    })
    let abiInputs = inputs != nil ? inputs! : [ABIv2.Element.InOut]()
    let outputs = try abiRecord.outputs?.map({ (output:ABIv2.Output) throws -> ABIv2.Element.InOut in
        let nativeOutput = try output.parse()
        return nativeOutput
    })
    let abiOutputs = outputs != nil ? outputs! : [ABIv2.Element.InOut]()
    let name = abiRecord.name != nil ? abiRecord.name! : ""
    let payable = abiRecord.stateMutability != nil ?
        (abiRecord.stateMutability == "payable" || abiRecord.payable!) : false
    let constant = (abiRecord.constant == true || abiRecord.stateMutability == "view" || abiRecord.stateMutability == "pure")
    let functionElement = ABIv2.Element.Function(name: name, inputs: abiInputs, outputs: abiOutputs, constant: constant, payable: payable)
    return functionElement
}

//fileprivate func parseFallback(abiRecord:ABIv2.Record) throws -> ABIv2.Element.Fallback {
//    let payable = (abiRecord.stateMutability == "payable" || abiRecord.payable!)
//    var constant = abiRecord.constant == true
//    if (abiRecord.stateMutability == "view" || abiRecord.stateMutability == "pure") {
//        constant = true
//    }
//    let functionElement = ABIv2.Element.Fallback(constant: constant, payable: payable)
//    return functionElement
//}
//
//fileprivate func parseConstructor(abiRecord:ABIv2.Record) throws -> ABIv2.Element.Constructor {
//    let inputs = try abiRecord.inputs?.map({ (input:ABIv2.Input) throws -> ABIv2.Element.InOut in
//        let nativeInput = try input.parse()
//        return nativeInput
//    })
//    let abiInputs = inputs != nil ? inputs! : [ABIv2.Element.InOut]()
//    var payable = false
//    if (abiRecord.payable != nil) {
//        payable = abiRecord.payable!
//    }
//    if (abiRecord.stateMutability == "payable") {
//        payable = true
//    }
//    let constant = false
//    let functionElement = ABIv2.Element.Constructor(inputs: abiInputs, constant: constant, payable: payable)
//    return functionElement
//}

extension ABIv2.Input {
    func parse() throws -> ABIv2.Element.InOut {
        let name = self.name != nil ? self.name! : ""
        let parameterType = try ABIv2TypeParser.parseTypeString(self.type)
        if case .tuple(types: _) = parameterType {
            let components = try self.components?.compactMap({ (inp: ABIv2.Input) throws -> ABIv2.Element.ParameterType in
                let input = try inp.parse()
                return input.type
            })
            let type = ABIv2.Element.ParameterType.tuple(types: components!)
            let nativeInput = ABIv2.Element.InOut(name: name, type: type)
            return nativeInput
        }
        else {
            let nativeInput = ABIv2.Element.InOut(name: name, type: parameterType)
            return nativeInput
        }
    }
    
    func parseForEvent() throws -> ABIv2.Element.Event.Input{
        let name = self.name != nil ? self.name! : ""
        let parameterType = try ABIv2TypeParser.parseTypeString(self.type)
        let indexed = self.indexed == true
        return ABIv2.Element.Event.Input(name:name, type: parameterType, indexed: indexed)
    }
}

extension ABIv2.Output {
    func parse() throws -> ABIv2.Element.InOut {
        let name = self.name != nil ? self.name! : ""
        let parameterType = try ABIv2TypeParser.parseTypeString(self.type)
        switch parameterType {
        case .tuple(types: _):
            let components = try self.components?.compactMap({ (inp: ABIv2.Output) throws -> ABIv2.Element.ParameterType in
                let input = try inp.parse()
                return input.type
            })
            let type = ABIv2.Element.ParameterType.tuple(types: components!)
            let nativeInput = ABIv2.Element.InOut(name: name, type: type)
            return nativeInput
        case .array(type: let subtype, length: let length):
            switch subtype {
            case .tuple(types: _):
                let components = try self.components?.compactMap({ (inp: ABIv2.Output) throws -> ABIv2.Element.ParameterType in
                    let input = try inp.parse()
                    return input.type
                })
                let nestedSubtype = ABIv2.Element.ParameterType.tuple(types: components!)
                let properType = ABIv2.Element.ParameterType.array(type: nestedSubtype, length: length)
                let nativeInput = ABIv2.Element.InOut(name: name, type: properType)
                return nativeInput
            default:
                let nativeInput = ABIv2.Element.InOut(name: name, type: parameterType)
                return nativeInput
            }
        default:
            let nativeInput = ABIv2.Element.InOut(name: name, type: parameterType)
            return nativeInput
        }
    }
}

// MARK: end of helper

// MARK: encode

extension ABIv2.Element {
    func encodeParameters(_ parameters: [AnyObject]) -> Data? {
        switch self {
        case .constructor(let constructor):
            guard parameters.count == constructor.inputs.count else {return nil}
            guard let data = ABIv2Encoder.encode(types: constructor.inputs, values: parameters) else {return nil}
            return data
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            guard parameters.count == function.inputs.count else {return nil}
            let signature = function.methodEncoding
            guard let data = ABIv2Encoder.encode(types: function.inputs, values: parameters) else {return nil}
            return signature + data
        }
    }
}

// MARK: decode

extension ABIv2.Element {
    func decodeReturnData(_ data: Data) -> [String:Any]? {
        switch self {
        case .constructor(_):
            return nil
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            if (data.count == 0 && function.outputs.count == 1) {
                let name = "0"
                let value = function.outputs[0].type.emptyValue
                var returnArray = [String:Any]()
                returnArray[name] = value
                if function.outputs[0].name != "" {
                    returnArray[function.outputs[0].name] = value
                }
                return returnArray
            }
            
            guard function.outputs.count*32 <= data.count else {return nil}
            var returnArray = [String:Any]()
            var i = 0;
            guard let values = ABIv2Decoder.decode(types: function.outputs, data: data) else {return nil}
            for output in function.outputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if output.name != "" {
                    returnArray[output.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        }
    }
    
    func decodeInputData(_ rawData: Data) -> [String: Any]? {
        var data = rawData
        var sig: Data? = nil
        switch rawData.count % 32 {
        case 0:
            break
        case 4:
            sig = rawData[0 ..< 4]
            data = Data(rawData[4 ..< rawData.count])
        default:
            return nil
        }
        switch self {
        case .constructor(let function):
            if (data.count == 0 && function.inputs.count == 1) {
                let name = "0"
                let value = function.inputs[0].type.emptyValue
                var returnArray = [String:Any]()
                returnArray[name] = value
                if function.inputs[0].name != "" {
                    returnArray[function.inputs[0].name] = value
                }
                return returnArray
            }
            
            guard function.inputs.count*32 <= data.count else {return nil}
            var returnArray = [String:Any]()
            var i = 0;
            guard let values = ABIv2Decoder.decode(types: function.inputs, data: data) else {return nil}
            for input in function.inputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if input.name != "" {
                    returnArray[input.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            if sig != nil && sig != function.methodEncoding {
                return nil
            }
            if (data.count == 0 && function.inputs.count == 1) {
                let name = "0"
                let value = function.inputs[0].type.emptyValue
                var returnArray = [String:Any]()
                returnArray[name] = value
                if function.inputs[0].name != "" {
                    returnArray[function.inputs[0].name] = value
                }
                return returnArray
            }
            
            guard function.inputs.count*32 <= data.count else {return nil}
            var returnArray = [String:Any]()
            var i = 0;
            guard let values = ABIv2Decoder.decode(types: function.inputs, data: data) else {return nil}
            for input in function.inputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if input.name != "" {
                    returnArray[input.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        }
    }
}


