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
import ethers
import CoreNFC

class ABTReaderManager: NSObject {
    var nfcTag: NFCISO7816Tag!
    var signPrivateKeyClosure: ((String) -> ())?
    var freezeStatusClosure: ((Bool?) -> ())?
    var unfreezeLeftCountClosure: ((Int) -> ())?
    var freezeResultClosure: ((FreezeResult) -> ())?
    
    private var apdu: Apdu = .none
    private var connectStatus: CardConnecetStatus = .disconnected
    private var absentCount = 0
    private var random = ""
    private var publicKey: Data?
    private var status = ""
    private var isFrozen: Bool?
    private var isParseToSetFrozenStatus = true
    private var certP1 = 0
    private var cert = Data()
    private var card = Card()
}

extension ABTReaderManager {
    
    func getConnectStatus() -> CardConnecetStatus {
        return connectStatus
    }
    
    func setConnectStatus(status: CardConnecetStatus) {
        connectStatus = status
    }
    
    /// id不为空，说明为HTTP模拟，否则为实体币
    func signPrivateKey(hashStr: String, id: Int? = nil) {
        apdu = .signPrivateKey
        let tv = Tlv.generate(tag: Data(hex: TagTransactionHash), value: Data(hex: hashStr))
        let serialData = Tlv.encode(tv: tv)
        let apduStr = apdu.value + serialData.toHexString()
        if let id = id {
            transceiveApdu(apdu: apdu, value: apduStr, id: id)
        } else {
            let data = Data(hex: apduStr)
            guard let apdu7816 = NFCISO7816APDU(data: data) else { return }
            nfcTag.sendCommand(apdu: apdu7816) { (data, _, _, error) in
                guard error == nil else { return }
                self.signPrivateKey(rawApdu: data)
            }
        }
    }
    
    func getFreezeStatus() {
        // call SDK to get frozen status
        isParseToSetFrozenStatus = false
        sendApdu(apdu: .freezeStatus)
    }
    func getUnFreezeLeftCount() {
        sendApdu(apdu: .unfreezeLeftCount)
    }
    func freeze(pinStr: String) {
        guard let pinData = pinStr.data(using: .utf8) else { return }
        apdu = .freeze
        let tv = Tlv.generate(tag: Data(hex: TagFreeze), value: pinData)
        let serialData = Tlv.encode(tv: tv)
        let apduStr = apdu.value + serialData.toHexString()
        
        let data = Data(hex: apduStr)
        guard let apdu7816 = NFCISO7816APDU(data: data) else { return }
        nfcTag.sendCommand(apdu: apdu7816) { (data, _, _, error) in
            guard error == nil else { return }
            self.parseFreeze(rawApdu: data)
        }
    }
    func unfreeze(pinStr: String) {
        guard let pinData = pinStr.data(using: .utf8) else { return }
        apdu = .unfreeze
        let tv = Tlv.generate(tag: Data(hex: TagFreeze), value: pinData)
        let serialData = Tlv.encode(tv: tv)
        let apduStr = apdu.value + serialData.toHexString()
        
        let data = Data(hex: apduStr)
        guard let apdu7816 = NFCISO7816APDU(data: data) else { return }
        nfcTag.sendCommand(apdu: apdu7816) { (data, _, _, error) in
            guard error == nil else { return }
            self.parseFreeze(rawApdu: data)
        }
    }
}

extension ABTReaderManager {
    
    private func throwError(error: CardReaderError) {
        connectStatus = .error
        CardReaderManager.shared.didCardRead(card: nil, error: error)
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
        
        guard let data = apduData else { return }
        guard let apdu7816 = NFCISO7816APDU(data: data) else { return }
        nfcTag.sendCommand(apdu: apdu7816) { (data, _, _, error) in
            guard error == nil else { return }
            switch self.apdu {
            case .publicKey:
                self.savePublicKey(rawApdu: data)
                self.sendApdu(apdu: .cardStatus)
            case .cardStatus:
                self.saveCardStatus(rawApdu: data)
                self.sendApdu(apdu: .freezeStatus)
            case .freezeStatus:
                self.parseFreezeStatus(rawApdu: data)
                self.isParseToSetFrozenStatus ? self.sendApdu(apdu: .certificate("\(self.certP1)")) : ()
            case .certificate:
                self.judgeAndVerifyCertificate(rawApdu: data)
            case .verifyDevice:
                self.verifyDevice(rawApdu: data)
                self.sendApdu(apdu: .verifyBlockchain)
            case .verifyBlockchain:
                self.verifyBlockchain(rawApdu: data)
            case .signPrivateKey:
                self.signPrivateKey(rawApdu: data)
            case .unfreezeLeftCount:
                self.parseUnFreezeLeftCount(rawApdu: data)
            case .freeze:
                self.parseFreeze(rawApdu: data)
            case .unfreeze:
                self.parseFreeze(rawApdu: data)
            default: break
            }
        }
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
    
    /// 通过NFC读取，没有末尾的9000，直接解析即可
    func getTv(rawApdu: Data) -> Tv? {
        return Tlv.decode(data: rawApdu)
    }
    
    /// verify apdu version
    private func verifyApduVersion(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { throwError(error: .apduReaderError); return }
        let tag = Data(hex: TagApduVersion)
        guard let version = tv[tag] else { throwError(error: .apduReaderError); return }
        guard let versionStr = String(data: version, encoding: .utf8) else { throwError(error: .apduReaderError); return }
        if versionStr.compare(VersionApdu) == .orderedDescending { // versionStr > VersionApdu
            throwError(error: .apduVersionTooLow)
            return
        }
        sendApdu(apdu: .publicKey)
    }
    
    /// Save public key for global use
    func savePublicKey(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { throwError(error: .apduReaderError); return }
        let tag = Data(hex: TagBlockChainPublicKey)
        guard let publicKey = tv[tag] else { throwError(error: .apduReaderError); return }
        self.publicKey = publicKey
    }
    
    /// Save card safe status for global use
    func saveCardStatus(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { throwError(error: .apduReaderError); return }
        let tag = Data(hex: TagTransactionSignatureCounter)
        guard let status = tv[tag] else { throwError(error: .apduReaderError); return }
        self.status = status.toHexString()
    }
    
    func getCertificateData(rawApdu: Data) -> Data? {
        guard let tv = getTv(rawApdu: rawApdu) else { throwError(error: .apduReaderError); return nil}
        let tag = Data(hex: TagDeviceCertificate)
        guard let cert = tv[tag] else { return nil }
        return cert
    }
    func judgeAndVerifyCertificate(rawApdu: Data) {
        cert.append(rawApdu)
        if rawApdu.count < 255 {
            let tv = Tlv.decode(data: cert)
            let tag = Data(hex: TagDeviceCertificate)
            guard let certValue = tv[tag] else { return }
            cert = certValue
            verifyCertificate()
        } else {
            sendApdu(apdu: .certificate("\(certP1 + 1)"))
        }
    }
    
    /// if id is not nil, means you use HTTP Server to simulate NFC Device
    func verifyCertificate(id: Int? = nil) {
        guard !cert.isEmpty else { throwError(error: .apduReaderError); return }
        guard let certParser = CertificateParser(hexCert: cert.toBase64String()) else { return }
        if certParser.version > VersionCertificate {
            throwError(error: .apduVersionTooLow)
            return
        }
        guard certParser.blockchain == "80000000" || certParser.blockchain.lowercased() == "8000003c" else {
            throwError(error: .apduVersionTooLow)
            return
        }
        card = certParser.toCard()
        card.publicKeyData = publicKey
        card.address = EnoteFormatter.address(publicKey: publicKey, network: card.network)
        card.isSafe = status == "0000"
        card.isFrozen = isFrozen
        let certificate = card.tbsCertificate.toHexString()
        let certificateAndSig = card.tbsCertificateAndSig.toHexString()
        let postion = certificateAndSig.positionOf(subStr: certificate)
        let certficateStr = certificateAndSig.subString(to: postion + certificate.count)
        
        func verify(publicKey: Data?) {
            guard let publicKey = publicKey else { throwError(error: .apduReaderError); return }
            guard Verification.verify(r: card.r, s: card.s, org: certficateStr, publicKey: publicKey.toHexString()) else {
                throwError(error: .verifyError); return
            }
            guard let id = id else { sendApdu(apdu: .verifyDevice); return }
            guard let apdu = getApduData(tag: TagChallenge, apdu: .verifyDevice) else { throwError(error: .apduReaderError); return }
            transceiveApdu(apdu: .verifyDevice, value: apdu.toHexString(), id: id)
        }
        
        let data = AbiParser.encodePublicKeyData(issuer: card.issuer.uppercased(), batch: card.manufactureBatch)
        let isTestOrDemo = card.serialNumber.lowercased().hasPrefix(EthCallTestPrefix) || card.serialNumber.lowercased().hasPrefix(EthCallDemoPrefix)
        let network: Network = isTestOrDemo ? .kovan : .ethereum
        NetworkManager.shared.call(network: network, toAddress: network.contractAddress, data: data) { [weak self] (result, error) in
            guard error == nil else { self?.throwError(error: .apduReaderError); return }
            let publicKey = AbiParser.decodePublicKeyData(result: result)
            verify(publicKey: publicKey)
        }
    }
    
    func verifyDevice(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { throwError(error: .apduReaderError); return }
        let tagSign = Data(hex: TagVerificationSignature), tagSalt = Data(hex: TagSalt)
        guard let signature = tv[tagSign], let salt = tv[tagSalt] else {
            throwError(error: .verifyError); return
        }
        let org = random.appending(salt.toHexString())
        let r = signature.subdata(in: 0..<32).toHexString()
        let s = signature.subdata(in: 32..<signature.count).toHexString()
        guard Verification.verify(r: r, s: s, org: org, publicKey: card.publicKey) else {
            throwError(error: .verifyError); return
        }
    }
    
    func verifyBlockchain(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { throwError(error: .apduReaderError); return }
        let typeSignature = Data(hex: TagVerificationSignature), typeSalt = Data(hex: TagSalt)
        guard let signature = tv[typeSignature], let salt = tv[typeSalt], let publicKey = publicKey else {
            throwError(error: .verifyError); return
        }
        let org = random.appending(salt.toHexString())
        let r = signature.subdata(in: 0..<32).toHexString()
        let s = signature.subdata(in: 32..<signature.count).toHexString()
        guard Verification.verify(r: r, s: s, org: org, publicKey: publicKey.toHexString()) else {
            throwError(error: .verifyError); return
        }
        // card read flow over
        connectStatus = .connected
        absentCount = 0
        CardReaderManager.shared.didCardRead(card: card, error: nil)
    }
    
    func signPrivateKey(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { throwError(error: .apduReaderError); return }
        let tag = Data(hex: TagTransactionSignature)
        guard let signature = tv[tag], let privateStr = BTCHexFromData(signature) else {
            return
        }
        signPrivateKeyClosure?(privateStr)
    }
    
    func parseFreezeStatus(rawApdu: Data) {
        isFrozen = nil
        guard let tv = getTv(rawApdu: rawApdu) else { return }
        let tag = Data(hex: TagFreezeStatus)
        guard let statusData = tv[tag], let freezeStatus = BTCHexFromData(statusData) else { freezeStatusClosure?(nil); return }
        isFrozen = freezeStatus != "00"
        freezeStatusClosure?(isFrozen)
    }
    func parseUnFreezeLeftCount(rawApdu: Data) {
        guard let tv = getTv(rawApdu: rawApdu) else { return }
        let tag = Data(hex: TagUnFreezeLeftCount)
        guard let unfreezeCountData = tv[tag], let unfreezeCount = BTCHexFromData(unfreezeCountData) else { return }
        unfreezeLeftCountClosure?(BigNumber(hexString: unfreezeCount.addHexPrefix())?.integerValue ?? 0)
    }
    func parseFreeze(rawApdu: Data) {
        if rawApdu.toHexString() == "9000" {
            freezeResultClosure?(.success)
        } else if rawApdu.toHexString() == "6982" {
            freezeResultClosure?(.wrongFreezePin)
        } else if rawApdu.toHexString() == "6985" {
            freezeResultClosure?(.frozenAlready)
        }
    }
}

// MARK: NFC Reader
extension ABTReaderManager {
    
    /// 默认第一个命令为version命令，其他的在验证后继续发送
    public func apduHanding() {
        
        let apduData = Data(hex: Apdu.version.value)
        guard let apdu7816 = NFCISO7816APDU(data: apduData) else { return }
        nfcTag.sendCommand(apdu: apdu7816) { (data, _, _, error) in
            guard error == nil else { return }
            self.verifyApduVersion(rawApdu: data)
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
        case .none, .version, .freezeStatus, .unfreezeLeftCount, .freeze, .unfreeze: break
        }
    }
}
