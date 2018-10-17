//
//  ModelInterface.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/14.
//  Copyright © 2018 Smiacter. All rights reserved.
//

public enum ConfirmStatus {
    case none
    case confirmed
    case confirming
}

public struct UtxoModel {
    var txid: String = ""
    var index: UInt32 = 0
    var script: String = ""
    var value: BTCAmount = 0
    var confirmations: UInt = 0
    var comfirmed: Bool = false
}

//extension UtxoModel: _ObjectiveCBridgeable {
//
//    typealias _ObjectiveCType = UtxoOcModel
//
//    static func _unconditionallyBridgeFromObjectiveC(_ source: UtxoOcModel?) -> UtxoModel {
//        return UtxoModel(txid: source!.txid, index: source!.index, script: source!.script, value: source!.value, confirmations: UInt(source!.confirmations), comfirmed: source!.comfirmed)
//    }
//
//    // 判断是否能转换成Objective-C对象
//    static func _isBridgedToObjectiveC() -> Bool {
//        return true
//    }
//    // 获取转换的目标类型
//    static func _getObjectiveCType() -> Any.Type {
//        return _ObjectiveCType.self
//    }
//    // 转换成Objective-C对象
//    func _bridgeToObjectiveC() -> _ObjectiveCType {
//        return UtxoOcModel(txid: txid, index: index, script: script, value: value, confirmations: UInt32(confirmations), comfirmed: comfirmed)
//    }
//    // 强制将Objective-C对象转换成Swift结构体类型
//    static func _forceBridgeFromObjectiveC(_ source: _ObjectiveCType, result: inout UtxoModel?) {
//        result = UtxoModel(txid: source.txid, index: source.index, script: source.script, value: source.value, confirmations: UInt(source.confirmations), comfirmed: source.comfirmed)
//    }
//    // 有条件地将Objective-C对象转换成Swift结构体类型
//    static func _conditionallyBridgeFromObjectiveC(_ source: _ObjectiveCType, result: inout UtxoModel?) -> Bool {
//        _forceBridgeFromObjectiveC(source, result: &result)
//        return true
//    }
//
//}
