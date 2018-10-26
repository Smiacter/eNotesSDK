//
//  Validation.swift
//  eNotesSDKTest
//
//  Created by Smiacter on 2018/10/18.
//  Copyright © 2018 eNotes. All rights reserved.
//

import UIKit
import eNotesSDKPre
import ethers

extension String {
    
    /// Confirm whether a card address is valid
    func isValidAddress(blockchain: Blockchain) -> Bool {
        guard !self.isEmpty else {
            return false
        }
        switch blockchain {
        case .bitcoin:
            if BTCAddress(string: self) == nil {
                return false
            }
        case .ethereum:
            if self.count != 42 {
                return false
            } else if Address(string: self) == nil {
                return false
            }
        }
        
        return true
    }
}
