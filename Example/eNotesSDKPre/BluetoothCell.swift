//
//  BluetoothCell.swift
//  eNotesSDKTest
//
//  Created by Smiacter on 2018/10/18.
//  Copyright © 2018 eNotes. All rights reserved.
//

import UIKit
import eNotesSDKPre
import CoreBluetooth

class BluetoothCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var connectStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        CardReaderManager.shared.addObserver(observer: self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension BluetoothCell: CardReaderObserver {
    func didCardRead(card: Card?, error: CardReaderError?) {
        
    }
    
    func didBluetoothConnected(peripheral: CBPeripheral) {
        connectStatusLabel.text = "ble connected"
    }
    
    func didBluetoothDisconnect(peripheral: CBPeripheral?) {
        connectStatusLabel.text = "ble disconnected"
    }
    
    func didCardAbsent() {
        connectStatusLabel.text = "card absent"
    }
    
    func didCardPresent() {
        connectStatusLabel.text = "card presented"
    }
}
