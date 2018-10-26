//
//  BluetoothTableViewController.swift
//  eNotesSDKTest
//
//  Created by Smiacter on 2018/10/18.
//  Copyright © 2018 eNotes. All rights reserved.
//

import UIKit
import eNotesSDKPre
import CoreBluetooth

class BluetoothTableViewController: UITableViewController {
    var peripherals = [CBPeripheral]() {
        didSet { tableView.reloadData() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        CardReaderManager.shared.addObserver(observer: self)
    }

    @IBAction func scanBluetoothAction(_ sender: Any) {
        CardReaderManager.shared.startBluetoothScan()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue", let detailVC = segue.destination as? DetailTableViewController, let card = sender as? Card {
            detailVC.card = card
        }
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothCell", for: indexPath) as? BluetoothCell else { fatalError("invalid cell type") }
        cell.nameLabel.text = peripherals[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CardReaderManager.shared.connectBluetooth(peripheral: peripherals[indexPath.row])
    }
}

extension BluetoothTableViewController: CardReaderObserver {
    
    func didBluetoothUpdateState(state: CBManagerState) {
        switch state {
        case .poweredOff:
            Alert.show(leftTxt: nil, msg: "Bluetooth is off, please open on it", title: "TIP")
        case .poweredOn:
            CardReaderManager.shared.startBluetoothScan()
        default:
            print("Bluetooth state: \(state)")
        }
    }
    
    func didDiscover(peripherals: [CBPeripheral]) {
        self.peripherals = peripherals
    }
    
    func didCardRead(card: Card?, error: CardReaderError?) {
        guard error == nil else {
            // error handle
            print("CardReaderError: \(String(describing: error))")
            return
        }
        guard card != nil else { return }
        guard let curVC = UIViewController.current(), curVC.isKind(of: BluetoothTableViewController.self) else { return }
        performSegue(withIdentifier: "DetailSegue", sender: card!)
    }
}
