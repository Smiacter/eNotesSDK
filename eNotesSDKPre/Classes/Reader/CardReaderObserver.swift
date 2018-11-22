//
//  CardReaderObserver.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/9/27.
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

import UIKit
import CoreBluetooth

/// protocol including Bluetooth and CardReader
public protocol CardReaderObserver: class {
    /// Discoverd peripherals
    func didDiscover(peripherals: [CBPeripheral])
    /// Bluetooth connected, when attached to reader
    func didBluetoothConnected(peripheral: CBPeripheral)
    /// Bluetooth disconnected, error occurred or manually disconnect
    func didBluetoothDisconnect(peripheral: CBPeripheral?)
    /// Bluetooth state changed, see CBManagerState for more
    func didBluetoothUpdateState(state: CBManagerState)
    /// Card reader progress done, return card info if success, return error if fail
    func didCardRead(card: Card?, error: CardReaderError?)
    /// Card did present on NFC device
    func didCardPresent()
    /// Card did absent on NFC device
    func didCardAbsent()
    
    // --- for test ---
    ///
    func didDiscover(devices: [ServerBluetoothDevice])
}

public extension CardReaderObserver {
    
    func didDiscover(peripherals: [CBPeripheral]) {}
    func didBluetoothConnected(peripheral: CBPeripheral) {}
    func didBluetoothDisconnect(peripheral: CBPeripheral?) {}
    func didBluetoothUpdateState(state: CBManagerState) {}
    func didCardPresent() {}
    func didCardAbsent() {}
    
    // --- for test ---
    ///
    func didDiscover(devices: [ServerBluetoothDevice]) {} 
}
