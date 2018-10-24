//
//  DetailTableViewController.swift
//  eNotesSDKTest
//
//  Created by Smiacter on 2018/10/18.
//  Copyright © 2018 eNotes. All rights reserved.
//

import UIKit
import CoreBluetooth
import eNotesSDKPre
import ethers

class DetailTableViewController: UITableViewController {
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var facevalueLabel: UILabel!
    @IBOutlet weak var safeStatusLabel: UILabel!
    @IBOutlet weak var manufactureLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var productionDateLabel: UILabel!
    var card: Card?
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        CardReaderManager.shared.addObserver(observer: self)
        configure()
        getBalance()
    }
    
    func configure() {
        guard let card = card else { return }
        typeLabel.text = card.blockchain == .bitcoin ? "Bitcoin" : "Ethereum"
        addressLabel.text = card.address
        facevalueLabel.text = "\(card.deno)"
        safeStatusLabel.text = "\(card.isSafe ? "Safe" : "Dangerous")"
        manufactureLabel.text = card.issuer
        serialNumberLabel.text = card.serialNumber
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        productionDateLabel.text = formatter.string(from: card.manufactureTime)
    }
    
    func getBalance() {
        guard let card = card else { return }
        NetworkManager.shared.getBalance(blockchain: card.blockchain, network: card.network, address: card.address) { [weak self] (balance, error) in
            guard error == nil, let self = self else { return }
            self.balanceLabel.text = balance
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "WithdrawSegue", let withdrawVC = segue.destination as? WithdrawTableViewController, let card = sender as? Card else { return }
        withdrawVC.card = card
        withdrawVC.balance = balanceLabel.text
    }

    @IBAction func withdrawAction(_ sender: Any) {
        guard let balance = BigNumber(hexString: balanceLabel.text)?.integerValue, balance > 0 else {
            Alert.show(leftTxt: nil, msg: "Balance is 0, can't send transaction", title: "Tip")
            return
        }
        performSegue(withIdentifier: "WithdrawSegue", sender: card)
    }
}

extension DetailTableViewController: CardReaderObserver {
    
    func didCardRead(card: Card?, error: CardReaderError?) {
        guard error == nil, let curVC = UIViewController.current(), curVC.isKind(of: DetailTableViewController.self) else { return }
        self.card = card
        configure()
        getBalance()
    }
}
