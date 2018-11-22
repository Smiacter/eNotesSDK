//
//  ABTReaderManager.swift
//  Alamofire
//
//  Created by Smiacter on 2018/10/10.
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

class ABTReaderManager: NSObject {
    var manager = ABTBluetoothReaderManager()
    var reader : ABTBluetoothReader!
    var signPrivateKeyClosure: ((String) -> ())?
    
    private var apdu: Apdu = .none
    private var random = ""
    private var publicKey: Data?
    private var status = ""
    private var certP1 = 0
    private var cert = Data()
    private var card = Card()
}

extension ABTReaderManager {
    
    func detectReader(with peripheral: CBPeripheral) {
        manager.delegate = self
        manager.detectReader(with: peripheral)
    }
    
    func signPrivateKey(hashStr: String, id: Int? = nil) {
        apdu = .signPrivateKey
        let tv = Tlv.generate(tag: Data(hex: TagTransactionHash), value: Data(hex: hashStr))
        let serialData = Tlv.encode(tv: tv)
        let apduStr = apdu.value + serialData.toHexString()
        guard let id = id else { reader.transmitApdu(Data(hex: apduStr)); return }
        transceiveApdu(apdu: apdu, value: apduStr, id: id)
    }
}

// MARK: Card init

extension ABTReaderManager {
    
    /// Authenticate the reader
    func authenticate() {
        let masterKey = Data(hex: MasterKey)
        reader.authenticate(withMasterKey: masterKey)
    }
    
    func enablePolling() {
        if reader.isKind(of: ABTAcr1255uj1Reader.self) {
            let command: [UInt8] = [0xE0, 0x00, 0x00, 0x40, 0x01]
            reader.transmitEscapeCommand(command, length: UInt(command.count))
        }
    }
    
    func powerOn() {
        reader.powerOnCard()
    }
}

// MARK: Apdu command handle

extension ABTReaderManager {
    
    /// Send apdu command to card
    ///
    /// - Parameters:
    ///  - apdu: specified apdu command except 'signPrivateKey'
    func sendApdu(apdu: Apdu) {
        self.apdu = apdu
        
        var apduData: Data?
        switch apdu {
        case .verifyDevice:
            apduData = getApduData(tag: TagChallenge, apdu: apdu)
        case .verifyBlockchain:
            apduData = getApduData(tag: TagChallenge, apdu: apdu)
        default:
            apduData = Data(hex: apdu.value)
        }
        
        reader.transmitApdu(apduData)
    }
    
    /// Get apdu data, for type verifyDevice, verifyBlockchain
    ///
    /// - Parameters:
    ///  - tag: TLV's T: tag
    ///  - apdu: type verifyDevice, verifyBlockchain
    func getApduData(tag: String, apdu: Apdu) -> Data? {
        do {
            random = try SecRandom.generate(bytes: 32).toHexString()
            let serialData = Tlv.encode(tv: Tlv.generate(tag: Data(hex: tag), value: Data(hex: random)))
            let apduStr = apdu.value + serialData.toHexString()
            let apduData = Data(hex: apduStr)
            return apduData
        } catch {}
        
        return nil
    }
    
    func getTv(rawApdu: Data) -> Tv? {
        guard let apdu = EnoteFormatter.stripApduTail(rawApdu: rawApdu) else {
            CardReaderManager.shared.didCardRead(card: nil, error: .apduReaderError)
            return nil
        }
        return Tlv.decode(data: apdu)
    }
    
    /// verify apdu version
    private func verifyApduVersion(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { return }
        let tag = Data(hex: TagApduVersion)
        guard let version = tv[tag] else {
            CardReaderManager.shared.didCardRead(card: nil, error: .apduReaderError)
            return
        }
        guard let versionStr = String(data: version, encoding: .utf8), versionStr == VersionApdu else {
            CardReaderManager.shared.didCardRead(card: nil, error: .apduVersionTooLow)
            return
        }
        sendApdu(apdu: .publicKey)
    }
    
    /// Save public key for global use
    func savePublicKey(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { return }
        let tag = Data(hex: TagBlockChainPublicKey)
        guard let publicKey = tv[tag] else {
            CardReaderManager.shared.didCardRead(card: nil, error: .apduReaderError)
            return
        }
        self.publicKey = publicKey
    }
    
    /// Save card safe status for global use
    func saveCardStatus(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { return }
        let tag = Data(hex: TagTransactionSignatureCounter)
        guard let status = tv[tag] else {
            CardReaderManager.shared.didCardRead(card: nil, error: .apduReaderError)
            return
        }
        self.status = status.toHexString()
    }
    
    func getCertificateData(rawApdu: Data) -> Data? {
        guard let tv = getTv(rawApdu: rawApdu) else { return nil}
        let tag = Data(hex: TagDeviceCertificate)
        guard let cert = tv[tag] else { return nil }
        return cert
    }
    
    /// if id is not nil, means you use HTTP Server to simulate NFC Device
    func verifyCertificate(id: Int? = nil) {
        guard !cert.isEmpty else { return }
        guard let certParser = CertificateParser(hexCert: cert.toBase64String()) else { return }
        guard certParser.version == VersionCertificate else { CardReaderManager.shared.didCardRead(card: nil, error: .apduVersionTooLow); return }
        card = certParser.toCard()
        card.publicKeyData = publicKey
        card.address = EnoteFormatter.address(publicKey: publicKey, network: card.network)
        card.isSafe = status == "0000"
        let certificate = card.tbsCertificate.toHexString()
        let certificateAndSig = card.tbsCertificateAndSig.toHexString()
        let postion = certificateAndSig.positionOf(subStr: certificate)
        let certficateStr = certificateAndSig.subString(to: postion + certificate.count)
        
        func verify(publicKey: Data?) {
            guard let publicKey = publicKey else { return }
            guard Verification.verify(r: card.r, s: card.s, org: certficateStr, publicKey: publicKey.toHexString()) else {
                CardReaderManager.shared.didCardRead(card: nil, error: .verifyError)
                return
            }
            guard let id = id else { sendApdu(apdu: .verifyDevice); return }
            guard let apdu = getApduData(tag: TagChallenge, apdu: .verifyDevice) else { return }
            transceiveApdu(apdu: .verifyDevice, value: apdu.toHexString(), id: id)
        }
        
        let data = AbiParser.encodePublicKeyData(issuer: card.issuer.uppercased(), batch: card.manufactureBatch)
        let network: Network = card.serialNumber.lowercased().hasPrefix(EthCallTestPrefix) ? .kovan : .ethereum
        NetworkManager.shared.call(network: network, toAddress: network.contractAddress, data: data) { (result, error) in
            guard error == nil else { return }
            let publicKey = AbiParser.decodePublicKeyData(result: result)
            verify(publicKey: publicKey)
        }
    }
    
    func verifyDevice(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { return }
        let tagSign = Data(hex: TagVerificationSignature), tagSalt = Data(hex: TagSalt)
        guard let signature = tv[tagSign], let salt = tv[tagSalt] else {
            CardReaderManager.shared.didCardRead(card: nil, error: .verifyError)
            return
        }
        let org = random.appending(salt.toHexString())
        let r = signature.subdata(in: 0..<32).toHexString()
        let s = signature.subdata(in: 32..<signature.count).toHexString()
        guard Verification.verify(r: r, s: s, org: org, publicKey: card.publicKey) else {
            CardReaderManager.shared.didCardRead(card: nil, error: .verifyError)
            return
        }
    }
    
    func verifyBlockchain(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { return }
        let typeSignature = Data(hex: TagVerificationSignature), typeSalt = Data(hex: TagSalt)
        guard let signature = tv[typeSignature], let salt = tv[typeSalt], let publicKey = publicKey else {
            CardReaderManager.shared.didCardRead(card: nil, error: .verifyError)
            return
        }
        let org = random.appending(salt.toHexString())
        let r = signature.subdata(in: 0..<32).toHexString()
        let s = signature.subdata(in: 32..<signature.count).toHexString()
        guard Verification.verify(r: r, s: s, org: org, publicKey: publicKey.toHexString()) else {
            CardReaderManager.shared.didCardRead(card: nil, error: .verifyError)
            return
        }
        // card read flow over
        CardReaderManager.shared.didCardRead(card: card, error: nil)
    }
    
    func signPrivateKey(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { return }
        let tag = Data(hex: TagTransactionSignature)
        guard let signature = tv[tag], let privateStr = BTCHexFromData(signature) else {
            return
        }
        signPrivateKeyClosure?(privateStr)
    }
}

extension ABTReaderManager: ABTBluetoothReaderManagerDelegate {
    
    public func bluetoothReaderManager(_ bluetoothReaderManager: ABTBluetoothReaderManager!, didDetect reader: ABTBluetoothReader!, peripheral: CBPeripheral!, error: Error!) {
        self.reader = reader
        self.reader.delegate = self
        self.reader.attach(peripheral)
    }
}

extension ABTReaderManager: ABTBluetoothReaderDelegate {
    
    public func bluetoothReader(_ bluetoothReader: ABTBluetoothReader!, didAttach peripheral: CBPeripheral!, error: Error!) {
        guard error == nil else {return}
        // first step: authenticate the card when peripheral attach to reader
        authenticate()
    }
    
    public func bluetoothReader(_ bluetoothReader: ABTBluetoothReader!, didAuthenticateWithError error: Error!) {
        guard error == nil else { return }
        // second step: polling the card
        enablePolling()
    }
    
    public func bluetoothReader(_ bluetoothReader: ABTBluetoothReader!, didChangeCardStatus cardStatus: UInt, error: Error!) {
        guard error == nil else { return }
        if cardStatus == ABTBluetoothReaderCardStatusPresent {
            powerOn()
            CardReaderManager.shared.didCardPresent()
        } else if cardStatus == ABTBluetoothReaderCardStatusAbsent {
            CardReaderManager.shared.didCardAbsent()
        } else if cardStatus == ABTBluetoothReaderCardStatusPowerSavingMode {
            CardReaderManager.shared.didBluetoothDisconnect(peripheral: nil)
        }
    }
    
    public func bluetoothReader(_ bluetoothReader: ABTBluetoothReader!, didReturnAtr atr: Data!, error: Error!) {
        guard error == nil else { return }
        // start send apdu when card powered on
        cert = Data()
        certP1 = 0
        sendApdu(apdu: .aid)
    }
    
    public func bluetoothReader(_ bluetoothReader: ABTBluetoothReader!, didReturnResponseApdu apdu: Data!, error: Error!) {
        guard error == nil else { return }
        switch self.apdu {
        case .aid:
            sendApdu(apdu: .version)
        case .version:
            verifyApduVersion(rawApdu: apdu)
        case .publicKey:
            savePublicKey(rawApdu: apdu)
            sendApdu(apdu: .cardStatus)
        case .cardStatus:
            saveCardStatus(rawApdu: apdu)
            sendApdu(apdu: .certificate("\(certP1)"))
        case .certificate:
            if let data = getCertificateData(rawApdu: apdu) {
                self.cert.append(data)
                if data.count < 253 {
                    verifyCertificate()
                } else { // cert data max length is 253, if bigger than that we should get it several times
                    sendApdu(apdu: .certificate("\(certP1 + 1)"))
                }
            }
        case .verifyDevice:
            verifyDevice(rawApdu: apdu)
            sendApdu(apdu: .verifyBlockchain)
        case .verifyBlockchain:
            verifyBlockchain(rawApdu: apdu)
        case .signPrivateKey:
            signPrivateKey(rawApdu: apdu)
        case .none:break
        }
    }
}

// MARK: Use Http server to simulate real NFC Bluetooth device

extension ABTReaderManager {
    
    func transceiveApdu(apdu: Apdu, value: String, id: Int) {
        guard let parameter = ServerMethod.apduTransmit(apdu: value, id: id).parameter else { return }
        let request = ServerTransmitApduRequest()
        request.path = ServerMethod.apduTransmit(apdu: value, id: id).path
        request.parameters = parameter
        ServerNetwork.request(request) { [weak self] (response) in
            guard let self = self else { return }
            guard let model = response.decode(to: ServerApduResponseRaw.self) else { return }
            self.handleApduResponse(apdu: apdu, id: id, result: model.data.result)
        }
    }
    
    func handleApduResponse(apdu: Apdu, id: Int, result: String) {
        switch apdu {
        case .aid:
            cert = Data()
            certP1 = 0
            transceiveApdu(apdu: .publicKey, value: Apdu.publicKey.value, id: id)
        case .publicKey:
            savePublicKey(rawApdu: Data(hex: result))
            transceiveApdu(apdu: .cardStatus, value: Apdu.cardStatus.value, id: id)
        case .cardStatus:
            saveCardStatus(rawApdu: Data(hex: result))
            transceiveApdu(apdu: .certificate("\(certP1)"), value: Apdu.certificate("\(certP1)").value, id: id)
        case .certificate:
            if let data = getCertificateData(rawApdu: Data(hex: result)) {
                self.cert.append(data)
                if data.count < 253 {
                    verifyCertificate(id: id)
                } else { // cert data max length is 253, if bigger than that we should get it several times
                    transceiveApdu(apdu: .certificate("\(certP1 + 1)"), value: Apdu.certificate("\(certP1 + 1)").value, id: id)
                }
            }
        case .verifyDevice:
            verifyDevice(rawApdu: Data(hex: result))
            guard let data = getApduData(tag: TagChallenge, apdu: .verifyBlockchain) else { break }
            transceiveApdu(apdu: .verifyBlockchain, value: data.toHexString(), id: id)
        case .verifyBlockchain:
            verifyBlockchain(rawApdu: Data(hex: result))
        case .signPrivateKey:
            signPrivateKey(rawApdu: Data(hex: result))
        case .none, .version: break
        }
    }
}
