//
//  ABTReaderManager.swift
//  Alamofire
//
//  Created by Smiacter on 2018/10/10.
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
    
    func signPrivateKey(hashStr: String) {
        apdu = .signPrivateKey
        let tv = Tlv.generate(tag: Data(hex: TagTransactionHash), value: Data(hex: hashStr))
        let serialData = Tlv.encode(tv: tv)
        let apduStr = apdu.value + serialData.toHexString()
        let apduData = Data(hex: apduStr)
        reader.transmitApdu(apduData)
    }
}

// MARK: Card init

extension ABTReaderManager {
    
    /// authenticate the reader
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
    
    /// send apdu command to card
    ///
    /// - parameters:
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
    
    /// get apdu data, for type verifyDevice, verifyBlockchain
    ///
    /// - parameters:
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
    
    /// save public key for global use
    func savePublicKey(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { return }
        let tag = Data(hex: TagBlockChainPublicKey)
        guard let publicKey = tv[tag] else {
            CardReaderManager.shared.didCardRead(card: nil, error: .apduReaderError)
            return
        }
        self.publicKey = publicKey
        sendApdu(apdu: .cardStatus)
    }
    
    /// save card safe status for global use
    func saveCardStatus(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { return }
        let tag = Data(hex: TagTransactionSignatureCounter)
        guard let status = tv[tag] else {
            CardReaderManager.shared.didCardRead(card: nil, error: .apduReaderError)
            return
        }
        self.status = status.toHexString()
        sendApdu(apdu: .certificate("\(certP1)"))
    }
    
    func getCertificateData(rawApdu: Data) -> Data? {
        guard let tv = getTv(rawApdu: rawApdu) else { return nil}
        let tag = Data(hex: TagDeviceCertificate)
        guard let cert = tv[tag] else { return nil }
        return cert
    }
    
    func verifyCertificate() {
        guard !cert.isEmpty else { return }
        guard let certParser = CertificateParser(hexCert: cert.toBase64String()) else { return }
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
            sendApdu(apdu: .verifyDevice)
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
        sendApdu(apdu: .verifyBlockchain)
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
            CardReaderManager.shared.didBluetoothDisconnect()
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
            sendApdu(apdu: .publicKey)
        case .publicKey:
            savePublicKey(rawApdu: apdu)
        case .cardStatus:
            saveCardStatus(rawApdu: apdu)
        case .certificate:
            if let data = getCertificateData(rawApdu: apdu) {
                self.cert.append(data)
                if data.count < 253 {
                    verifyCertificate()
                } else {
                    sendApdu(apdu: .certificate("\(certP1 + 1)"))
                }
            }
        case .verifyDevice:
            verifyDevice(rawApdu: apdu)
        case .verifyBlockchain:
            verifyBlockchain(rawApdu: apdu)
        case .signPrivateKey:
            signPrivateKey(rawApdu: apdu)
        case .none:break
        }
    }
}
