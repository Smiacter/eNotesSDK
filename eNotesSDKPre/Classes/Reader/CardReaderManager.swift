//
//  CardReaderManager.swift
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
import ethers
import CoreNFC

public enum NFCScanType {
    case readCard, signTxHash, frozen
}

public class CardReaderManager: NSObject {
    
    public static let shared = CardReaderManager()
    private override init() {
        
    }
    
    // Switch - use http server to simulate card scan, connect, read process when not having NFC device
    public var useServerSimulate = false
    // if useServerSimulate is true, you must set server address, format: http://ip:port
    public var serverIp = ""
    // Observer
    private var observations = [ObjectIdentifier: Observation]()
    /// Http mock
    private var devices = [ServerBluetoothDevice]() {
        didSet { didDiscoverDevices() }
    }
    private var connectId: Int?
    
    // NFC
    private var nfcTagReaderSession: NFCTagReaderSession?
    private var abtManager = ABTReaderManager()
    private var nfcScanType = NFCScanType.readCard
    private var nfcDetectClosure: (() -> ())?
}

// MARK: NFC Reader - add at 2019.07.01
extension CardReaderManager: NFCTagReaderSessionDelegate {
    
    // MARK: NFC Method
    
    /// 唤起NFC扫描
    public func scanNFC(type: NFCScanType = .readCard) {
        // 使用局域网模拟
        guard !useServerSimulate else { getBluetoothDeviceList(); return }
        
        nfcScanType = type
        nfcTagReaderSession = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self)
//        nfcTagReaderSession?.alertMessage = "Place the device on the innercover of the passport"
        nfcTagReaderSession?.begin()
    }
    
    func invalidNFCSession() {
        nfcTagReaderSession?.invalidate()
        nfcTagReaderSession = nil
    }
    
    // MARK: NFCTagReaderSessionDelegate
    
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        invalidNFCSession()
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        for tag in tags {
            switch tag {
            case .iso7816(let tag7816):
                session.connect(to: tag) { [weak self] error in
                    guard error == nil else { return }
                    guard !tag7816.initialSelectedAID.isEmpty else { return }
                    self?.abtManager.nfcTag = tag7816
                    if self?.nfcScanType == .readCard {
                        self?.abtManager.apduHanding()
                    } else {
                        self?.nfcDetectClosure?()
                    }
                }
            default:
                ()
            }
        }
    }
}

// MARK: Observer

extension CardReaderManager {
    
    struct Observation {
        weak var observer: CardReaderObserver?
    }
    
    /// Add observer to handle card reader process wherever you need to konw the Bluetooth status or card info
    public func addObserver(observer: CardReaderObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }
    
    public func removeObserver(observer: CardReaderObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
    
    /// Http mock
    func didDiscoverDevices() {
        for (id, observation) in observations {
            guard let observer = observation.observer else { observations.removeValue(forKey: id); continue }
            observer.didDiscover(devices: devices)
        }
    }
    
    func didCardRead(card: Card?, error: CardReaderError?) {
        for (id, observation) in observations {
            guard let observer = observation.observer else { observations.removeValue(forKey: id); continue }
            observer.didCardRead(card: card, error: error)
        }
    }
}

// MARK: RawTransaction

public typealias rawtxClosure = ((String) -> ())?
extension CardReaderManager {
    
    /// Get ethereum raw transaction before send raw transaction
    ///
    /// - Parameters:
    ///  - sendAddress: send address
    ///  - toAddress: receiver address
    ///  - value: available ethereum balance
    ///  - gasPrice: gas price
    ///  - estimateGas: estimate gas
    ///  - nonce: nonce
    ///  - data: transfer data if send an ERC20 token
    ///  - closure:
    ///   - String: return the rawtx which will be used to send raw transaction
    public func getEthRawTransaction(sendAddress: String, toAddress: String, value: String, gasPrice: String, estimateGas: String, nonce: UInt, data: Data? = nil, closure: rawtxClosure) {
        
        func signTransactionHash(sendAddress: String, toAddress: String, value: String, gasPrice: String, estimateGas: String, nonce: UInt, data: Data? = nil, closure: rawtxClosure) {
            let transaction = Transaction()
            transaction.toAddress = Address(string: toAddress)
            transaction.gasPrice = BigNumber(hexString: gasPrice)
            transaction.gasLimit = BigNumber(hexString: estimateGas)
            transaction.nonce = nonce
            if let data = data {
                transaction.data = data
                transaction.value = BigNumber(integer: 0)
            } else {
                if let balanceNum = BigNumber(hexString: value), let valueNum = balanceNum.sub(transaction.gasPrice.mul(transaction.gasLimit)) {
                    transaction.value = valueNum
                }
            }
            
            let serializeData = transaction.unsignedSerialize()
            let secureData = SecureData.keccak256(serializeData)
            guard let hash = Hash(data: secureData) else {
                return
            }
            let hexHash = hash.hexString.subString(from: 2)
            
            abtManager.signPrivateKey(hashStr: hexHash, id: connectId)
            abtManager.signPrivateKeyClosure = { privateKey in
                let rStr = privateKey.subString(to: 64)
                let sStr = privateKey.subString(from: 64)
                guard let bigR = BTCBigNumber(hexString: rStr), let bigS = BTCBigNumber(hexString: sStr) else {
                    return
                }
                // MARK: be careful, use the unsafe pointer cast!!! check it!!!
                let s = unsafeBitCast(bigS.bignum, to: UnsafeMutablePointer<BIGNUM>.self)
                
                let ctx = BN_CTX_new()
                BN_CTX_start(ctx)
                
                let group = EC_GROUP_new_by_curve_name(714) // NID_secp256k1 -> 714 define in 'OpenSSL-Universal' -> 'obj_mac.h'
                let order = BN_CTX_get(ctx)
                let halfOrder = BN_CTX_get(ctx)
                EC_GROUP_get_order(group, order, ctx)
                BN_rshift1(halfOrder, order)
                
                if BN_cmp(s, halfOrder) > 0 {
                    BN_sub(s, order, s)
                }
                BN_CTX_end(ctx)
                BN_CTX_free(ctx)
                EC_GROUP_free(group)
                
                guard let rData = BTCBigNumber(bignum: bigR.bignum).unsignedBigEndian, let sData = BTCBigNumber(bignum: bigS.bignum).unsignedBigEndian else {
                    return
                }
                transaction.populateSignature(withR: rData, s: sData, address: Address(string: sendAddress))
                let serialize = transaction.serialize()
                let rawtx = BTCHexFromData(serialize).addHexPrefix()
                
                closure?(rawtx)
                self.invalidNFCSession()
            }
        }
        
        
        
        scanNFC(type: .signTxHash)
        nfcDetectClosure = {
            signTransactionHash(sendAddress: sendAddress, toAddress: toAddress, value: value, gasPrice: gasPrice, estimateGas: estimateGas, nonce: nonce, data: data, closure: closure)
        }
    }
    
    /// Get bitcoin raw transaction before send raw transaction
    ///
    /// - Parameters:
    ///  - publicKey: blockchain public key, Card model include this
    ///  - toAddress: receiver address
    ///  - utxos: available utxos
    ///  - network: mainet or testnet
    ///  - fee: estimate transaction fee
    ///  - closure:
    ///   - String: return the rawtx which will be used to send raw transaction
    public func getBtcRawTransaction(publicKey: Data, toAddress: String, utxos: [UtxoModel], network: Network, fee: BTCAmount, closure: rawtxClosure) {
        
        func signTransactionHash(publicKey: Data, toAddress: String, utxos: [UtxoModel], network: Network, fee: BTCAmount, closure: rawtxClosure) {
            
            DispatchQueue.global().async {
                var destinationAddress: BTCAddress?
                if network == .mainnet {
                    destinationAddress = BTCPublicKeyAddress(string: toAddress)
                } else if network == .testnet {
                    destinationAddress = BTCPublicKeyAddressTestnet(string: toAddress)
                }
                guard destinationAddress != nil else { return }
                
                var outputs: [BTCTransactionOutput] = []
                for utxo in utxos {
                    let output = BTCTransactionOutput()
                    output.value = utxo.value
                    output.script = BTCScript(data: BTCDataFromHex(utxo.script))
                    output.index = utxo.index
                    output.confirmations = utxo.confirmations
                    
                    guard let bigHashData = BTCDataFromHex(utxo.txid) else { return }
                    var hashData = Data()
                    for (_, data) in bigHashData.enumerated().reversed() {
                        hashData.append(data) // bigHashData.subdata(in: i-1 ..< i)
                    }
                    output.transactionHash = hashData
                    outputs.append(output)
                }
                
                outputs = outputs.sorted(by: { (output1, output2) -> Bool in
                    return output1.value < output2.value
                })
                
                let tx = BTCTransaction()
                var spentCoins: BTCAmount = 0
                for output in outputs {
                    let input = BTCTransactionInput()
                    input.previousHash = output.transactionHash
                    input.previousIndex = output.index
                    tx.addInput(input)
                    spentCoins += output.value
                }
                let paymentOutput = BTCTransactionOutput(value: spentCoins - fee, address: destinationAddress)
                tx.addOutput(paymentOutput)
                
                for (i, output) in outputs.enumerated() {
                    guard let inputs = tx.inputs as? [BTCTransactionInput] else { return }
                    do {
                        let input = inputs[i]
                        let data1 = tx.data
                        let hashType = BTCSignatureHashType.BTCSignatureHashTypeAll
                        let hash = try tx.signatureHash(for: output.script, inputIndex: UInt32(i), hashType: hashType)
                        let data2 = tx.data
                        guard data1 == data2 else { return }
                        guard let hexStr = BTCHexFromData(hash) else { return }
                        
                        self.abtManager.signPrivateKey(hashStr: hexStr, id: self.connectId)
                        
                        let sema = DispatchSemaphore(value: 0)
                        
                        self.abtManager.signPrivateKeyClosure = { privateKey in
                            let signature = BitcoinHelper.generateSignature(privateKey, hashtype: hashType)
                            guard let script = BTCScript() else { return }
                            script.appendData(signature)
                            script.appendData(publicKey)
                            input.signatureScript = script
                            sema.signal()
                        }
                        sema.wait()
                    } catch {
                        
                    }
                }
                
                closure?(tx.hex)
                self.invalidNFCSession()
            }
        }
        
        scanNFC(type: .signTxHash)
        nfcDetectClosure = {
            signTransactionHash(publicKey: publicKey, toAddress: toAddress, utxos: utxos, network: network, fee: fee, closure: closure)
        }
    }
}

// MARK: Freeze PIN

public typealias freezeStatusClosure = ((Bool?) -> ())?
public typealias unfreezeLeftCountClosure = ((Int) -> ())?
public typealias freezeResultClosure = ((FreezeResult, Int?) -> ())?
extension CardReaderManager {
    
    public func getFreezeStatus(closure: freezeStatusClosure) {
        scanNFC(type: .frozen)
        nfcDetectClosure = { [weak self] in
            self?.abtManager.getFreezeStatus()
            self?.abtManager.freezeStatusClosure = {
                self?.invalidNFCSession()
                closure?($0)
            }
        }
    }
    
    public func getUnfreezeLeftCount(closure: unfreezeLeftCountClosure) {
        scanNFC(type: .frozen)
        nfcDetectClosure = { [weak self] in
            self?.abtManager.getUnFreezeLeftCount()
            self?.abtManager.unfreezeLeftCountClosure = {
                self?.invalidNFCSession()
                closure?($0)
            }
        }
    }
    
    public func freeze(pinStr: String, closure: freezeResultClosure) {
        scanNFC(type: .frozen)
        nfcDetectClosure = { [weak self] in
            self?.abtManager.freeze(pinStr: pinStr)
            self?.abtManager.freezeResultClosure = { result, count in
                self?.invalidNFCSession()
                closure?(result, count)
            }
        }
    }
    public func unfreeze(pinStr: String, closure: freezeResultClosure) {
        scanNFC(type: .frozen)
        nfcDetectClosure = { [weak self] in
            self?.abtManager.unfreeze(pinStr: pinStr)
            self?.abtManager.freezeResultClosure = {
                self?.invalidNFCSession()
                closure?($0, $1)
            }
        }
    }
}

// MARK: Use Http server to simulate real NFC Bluetooth device

extension CardReaderManager {
    
    func getBluetoothDeviceList() {
        let request = ServerBluetoothListRequest()
        request.path = ServerMethod.bleList.path
        ServerNetwork.request(request) { [weak self ] (response) in
            guard let self = self else { return }
            guard let model = response.decode(to: ServerBluetoothDeviceRaw.self) else { return }
            self.devices = model.data
        }
    }
    
    func connectBluetoothDevice(address: String) {
        let request = ServerConnectBluetoothRequest()
        request.path = ServerMethod.bleConnect(address: address).path
        ServerNetwork.request(request) { [weak self ] (response) in
            guard let self = self else { return }
            guard let model = response.decode(to: ServerConnectResultRaw.self) else { return }
            self.connectId = model.data.id
            self.abtManager.transceiveApdu(apdu: .aid, value: Apdu.aid.value, id: model.data.id)
        }
    }
}
