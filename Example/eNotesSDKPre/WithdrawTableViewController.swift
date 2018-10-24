//
//  WithdrawTableViewController.swift
//  eNotesSDKTest
//
//  Created by Smiacter on 2018/10/18.
//  Copyright © 2018 eNotes. All rights reserved.
//

import UIKit
import eNotesSDKPre
import ethers
import AVFoundation

class WithdrawTableViewController: UITableViewController {
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var toAddressTextfield: UITextField!
    @IBOutlet weak var txFeeTextfield: UITextField!
    @IBOutlet weak var estimateGasTextfield: UITextField!
    @IBOutlet weak var gasPriceTextfield: UITextField!
    @IBOutlet weak var estimateGasCell: UITableViewCell!
    @IBOutlet weak var gasPriceCell: UITableViewCell!
    // card info
    var card: Card?
    var balance: String?
    // btc
    var unspend: [UtxoModel]?
    var btcEstimateFee: BTCAmount?
    // eth
    var nonce: UInt?
    var gasPrice: String?
    var estimateGas: String?
    var ethEstimateFee: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    func configure() {
        guard let card = card else { return }
        typeLabel.text = card.blockchain == .bitcoin ? "Bitcoin" : "Ethereum"
        addressLabel.text = card.address
        serialNumberLabel.text = card.serialNumber
        
        // hide last two cell, only eth has estimate gas and gas price
        estimateGasCell.isHidden = card.blockchain == .bitcoin
        gasPriceCell.isHidden = card.blockchain == .bitcoin
        if card.blockchain == .bitcoin {
            getUnspend()
        } else {
            getNonce()
            getGasPrice()
        }
    }
    
    func setEthTxFee() {
        guard let gasPrice = gasPrice, let estimateGas = estimateGas,
            let bigGasPrice = BigNumber(hexString: gasPrice),
            let bigEstimateGas = BigNumber(hexString: estimateGas) else { return }
        let ethTxFee = bigGasPrice.mul(bigEstimateGas)
        txFeeTextfield.text = ethTxFee?.decimalString
    }
    
    func sendEthRawTransaction() {
        guard let card = card, let balance = balance, let gasPrice = gasPrice, let estimateGas = estimateGas, let nonce = nonce, let toAddress = toAddressTextfield.text, !toAddress.isEmpty else {
            Alert.show(leftTxt: nil, msg: "Information is incomplete, please check", title: "Tip")
            return
        }
        CardReaderManager.shared.getEthRawTransaction(sendAddress: card.address, toAddress: toAddress, value: balance, gasPrice: gasPrice, estimateGas: estimateGas, nonce: nonce) { (rawtx) in
            self.sendRawTransaction(rawtx: rawtx)
        }
    }
    
    func sendBtcRawTransaction() {
        guard let card = card, let publicKey = card.publicKeyData, let unspend = unspend, let fee = btcEstimateFee, let toAddress = toAddressTextfield.text, !toAddress.isEmpty else {
            Alert.show(leftTxt: nil, msg: "Information is incomplete, please check", title: "Tip")
            return
        }
        CardReaderManager.shared.getBtcRawTransaction(publicKey: publicKey, toAddress: toAddress, utxos: unspend, network: card.network, fee: fee) { (rawtx) in
            self.sendRawTransaction(rawtx: rawtx)
        }
    }

    /// scan qrcode to query to address
    @IBAction func scanAction(_ sender: Any) {
        guard AVCaptureDevice.authorizationStatus(for: .video) != .denied, AVCaptureDevice.authorizationStatus(for: .video) != .restricted else {
            Alert.show(leftTxt: nil, msg: "Camera access denied, please open it in iPhone setting page", title: "Notice")
            return
        }
        let scanVC = WBQRCodeScanningVC()
        scanVC.scanDoneBlock = { [weak self] address in
            guard let self = self else { return }
            self.toAddressTextfield.text = address
            if let address = address, address.isValidAddress(blockchain: self.card!.blockchain), self.card!.blockchain == .ethereum {            
                self.getEstimateGas()
            }
        }
        navigationController?.pushViewController(scanVC, animated: true)
    }
    
    /// send raw transaction
    @IBAction func withdrawAction(_ sender: Any) {
        guard let card = card else { return }
        switch card.blockchain {
        case .bitcoin:
            sendBtcRawTransaction()
        case .ethereum:
            sendEthRawTransaction()
        }
    }
}

// MARK: Network
extension WithdrawTableViewController {
    
    // eth
    
    func getNonce() {
        NetworkManager.shared.getNonce(network: card!.network, address: card!.address) { [weak self] (nonce, error) in
            guard error == nil else {
                // error handle, use your code to replace
                print("error code: \(error!.code)\ndescription: \(error!.description)")
                return
            }
            guard let self = self else { return }
            self.nonce = nonce
        }
    }
    
    func getGasPrice() {
        NetworkManager.shared.getGasPrice(network: card!.network) { [weak self] (gasPrice, gasPriceModel, error) in
            guard error == nil else {
                print("error code: \(error!.code)\ndescription: \(error!.description)")
                return
            }
            guard let self = self else { return }
            self.gasPrice = gasPrice
            self.gasPriceTextfield.text = BigNumber(hexString: gasPrice)?.decimalString
            self.setEthTxFee()
        }
    }
    
    func getEstimateGas() {
        guard let balance = balance, let toAddress = toAddressTextfield.text else { return }
        NetworkManager.shared.getEstimateGas(network: card!.network, from: card!.address, to: toAddress, value: balance, data: nil) { [weak self] (estimateGas, error) in
            guard error == nil, let self = self else { return }
            self.estimateGas = estimateGas
            self.estimateGasTextfield.text = BigNumber(hexString: estimateGas)?.decimalString
            self.setEthTxFee()
        }
    }
    
    func sendRawTransaction(rawtx: String) {
        NetworkManager.shared.sendRawTransaction(blockchain: card!.blockchain, network: card!.network, rawtx: rawtx) { [weak self] (txid, error) in
            guard error == nil else { return }
            guard let self = self else { return }
            Alert.show(leftTxt: nil, msg: "send raw transaction success \ntxid: \(txid)", title: "Tip", confirmClosure: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    // btc

    func getUnspend() {
        NetworkManager.shared.getUnspend(network: card!.network, address: card!.address) { [weak self] (unspend, error) in
            guard error == nil, let self = self else { return }
            self.unspend = unspend
            self.getEstimateFee()
        }
    }
    
    func getEstimateFee() {
        NetworkManager.shared.getEstimateFee(network: card!.network) { [weak self] (fee, feeModel, error) in
            guard error == nil, let self = self, self.unspend != nil else { return }
            self.btcEstimateFee = fee.formatBtcFee(utxoCount: self.unspend!.count)
            self.txFeeTextfield.text = "\(self.btcEstimateFee ?? 0)"
        }
    }
}
