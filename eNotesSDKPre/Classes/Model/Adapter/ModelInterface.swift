//
//  ModelInterface.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/14.
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

/// Transaction receipt, only after sending raw transaction, can get transaction receipt
///
/// none: default value
/// confirmed: transaction done, 1 block will change to confirmed status
/// confirming: transaction is in progress
public enum ConfirmStatus {
    case none
    case confirmed
    case confirming
}

/// Unspend model
public struct UtxoModel {
    public var txid: String = ""
    public var index: UInt32 = 0
    public var script: String = ""
    public var value: BTCAmount = 0
    public var confirmations: UInt = 0
    public var comfirmed: Bool = false
}

/// Transaction history
public struct TransactionHistory {
    public var txid: String = ""
    public var time: TimeInterval = 0
    /// the unit is smallest, btc is satoshi, eth is wei
    public var value: Int64 = 0
    public var confirmations: Int = 0
    /// sender or receiver
    public var isSender: Bool = true
}

public struct MultiBalance {
    public var address: String = ""
    public var balance: String = ""
    
    public init(address: String, balance: String) {
        self.address = address
        self.balance = balance
    }
}
