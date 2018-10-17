//
//  ViewController.swift
//  eNotesSDKPre
//
//  Created by Smiacter on 10/17/2018.
//  Copyright (c) 2018 Smiacter. All rights reserved.
//

import UIKit
import eNotesSDKPre
import CoreBluetooth

class ViewController: UIViewController {
    var peris: [CBPeripheral] = []
    var card: Card?
    var utxos: [UtxoModel]?
    var fee: BTCAmount?
    let address = "moXKQWzARicF5mp9ttnvLvusu3SwJSCJih"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CardReaderManager.shared.startBluetoothScan()
        CardReaderManager.shared.addObserver(observer: self)
        
        NetworkManager.shared.getUnspend(network: .testnet, address: address) { (utxos, error) in
            guard error == nil else { return }
            self.utxos = utxos
            NetworkManager.shared.getEstimateFee(network: .testnet) { (fee, model, error) in
                self.fee = BTCAmount(148 * utxos.count + 44) * BTCAmount(fee) / 1000
            }
        }
    }
    
    @IBAction func scanBle(_ sender: UIButton) {
        CardReaderManager.shared.startBluetoothScan()
    }
    @IBAction func connectBle(_ sender: UIButton) {
        guard peris.count > 0 else { return }
        CardReaderManager.shared.connectBluetooth(peripheral: peris[0])
    }
    @IBAction func getEthRawTx(_ sender: Any) {
        CardReaderManager.shared.getEthRawTransaction(sendAddress: "0xE2e41374805d62fA2F5005479513fEbCD2B1c31B", toAddress: "0xE2e41374805d62fA2F5005479513fEbCD2B1c31B", value: "0x2c68af0bb140000", gasPrice: "0x04A817C800", estimateGas: "0x5208", nonce: 0, data: nil) { (rawtx) in
            print(rawtx)
        }
    }
    @IBAction func getBtcRawTx(_ sender: Any) {
        guard card != nil else { return }
        guard utxos != nil else { return}
        guard card!.publicKeyData != nil else { return }
        guard fee != nil else { return }
        
        CardReaderManager.shared.getBtcRawTransaction(publicKey: card!.publicKeyData!, toAddress: address, utxos: utxos!, network: .testnet, fee: fee!) { (rawtx) in
            print(rawtx)
        }
    }
}

extension ViewController: CardReaderObserver {
    
    func didDiscover(peripherals: [CBPeripheral]) {
        self.peris = peripherals
    }
    
    func didBluetoothConnected() {
        print("didBluetoothConnected")
    }
    
    func didBluetoothDisconnect() {
        print("didBluetoothDisconnect")
    }
    
    func didCardAbsent() {
        print("didCardAbsent")
    }
    
    func didCardPresent() {
        print("didCardPresent")
    }
    
    func didBluetoothUpdateState(state: CBManagerState) {
        print("didBluetoothUpdateState: \(state.rawValue)")
    }
    
    func didCardRead(card: Card?, error: CardReaderError?) {
        self.card = card
    }
}

