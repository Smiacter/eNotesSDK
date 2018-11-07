//
//  Alert.swift
//  eNotesSDKPre_Example
//
//  Created by Smiacter on 2018/10/23.
//  Copyright © 2018 CocoaPods. All rights reserved.
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

class Alert: NSObject {

    static func show(leftTxt: String? = "Cancel", rightTxt: String = "OK", msg: String, title: String?, cancelClosure: (() -> ())? = nil, confirmClosure: (() -> ())? = nil ) {
        guard let curVC = UIViewController.current() else { return }
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        if leftTxt != nil {
            let cancelAction = UIAlertAction(title: leftTxt, style: .cancel) { (cancel) in
                cancelClosure?()
            }
            alertController.addAction(cancelAction)
        }
        
        let confirmAction = UIAlertAction(title: rightTxt, style: .default) { (confirm) in
            confirmClosure?()
        }
        alertController.addAction(confirmAction)
        
        curVC.present(alertController, animated: true) {  }
    }
    
    static func showTextfield(confirmClosure: ((String?) -> ())?) {
        guard let curVC = UIViewController.current() else { return }
        
        let alertController = UIAlertController(title: "Enter IP Address", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (confirm) in
            guard let texts = alertController.textFields, texts.count == 1 else { return }
            confirmClosure?(texts[0].text)
        }
        alertController.addAction(confirmAction)
        
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Please enter your IP address"
        }
        
        curVC.present(alertController, animated: true) {  }
    }
}
