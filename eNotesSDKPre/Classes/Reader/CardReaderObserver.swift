//
//  CardReaderObserver.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/9/27.
//  Copyright © 2018 eNotes. All rights reserved.
//

import UIKit
import CoreBluetooth

/// protocol including Bluetooth and CardReader
public protocol CardReaderObserver: class {
    /// discoverd peripherals
    func didDiscover(peripherals: [CBPeripheral])
    /// Bluetooth connected, when attached to reader
    func didBluetoothConnected()
    /// Bluetooth disconnected, error occurred or manually disconnect
    func didBluetoothDisconnect()
    /// Bluetooth state changed, see CBManagerState for more
    func didBluetoothUpdateState(state: CBManagerState)
    func didCardRead(card: Card?, error: CardReaderError?)
    func didCardPresent()
    func didCardAbsent()
}
