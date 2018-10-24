# eNotesSDKPre

[![Version](https://img.shields.io/cocoapods/v/eNotesSDKPre.svg?style=flat)](https://cocoapods.org/pods/eNotesSDKPre)
[![License](https://img.shields.io/cocoapods/l/eNotesSDKPre.svg?style=flat)](https://cocoapods.org/pods/eNotesSDKPre)
[![Platform](https://img.shields.io/cocoapods/p/eNotesSDKPre.svg?style=flat)](https://cocoapods.org/pods/eNotesSDKPre)

Easy way to verify and manage your eNotes.



- [Description](#Description)
- [Features](#Features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#usage)
  - [CardReaderManager](#CardReaderManager)
  - [NetworkManager](#NetworkManager) 
- [Example](#Example)
- [License](#license)

## Description

The eNotesSDKPre is a Swift implementation of the verify and manage your eNotes through this app with  smarphones and bluetooth NFC reader which is sold separately.

## Features

- [x] Support BTC (mainnet and testnet)
- [x] Support ETH (mainnet , ropsten , rinkeby and kovan)
- [x] Support ERC20 token
- [x] Verify physical form of digital asserts with NFC and bluetooth
- [x] Provide most common use RPC request

## Requirements

- iOS 10.0+
- Xcode 10+
- Swift 4.2+

## Communication

- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/alamofire).
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

### CocoaPods

eNotesSDKPre is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your `Podfile`:

```ruby
pod 'eNotesSDKPre'
```

Then, run the following command:

```bash
pod install
```

### Project setting

When you compile your code, there maybe some error occur, try those way to resolve: 
- `Target` -> `Build Setting` -> `Enable Bitcode` set to No, this because internal implement we use [CoreBitcoin](https://github.com/oleganza/CoreBitcoin) to realize Bitcoin related function which doesn't enable bitcode
- `Target` -> `Build Setting` -> `Other Linker Flags` add `-ObjC` , this because we use [ACS](https://www.acs.com.hk/)'s Bluetooth NFC reader library which explicit declare we must add  `-ObjC` in `Other Linker Flags`

# Usage

## CardReaderManager

1. Add observer in your init code, such as `viewDidLoad` in a UIViewController

```
CardReaderManager.shared.addObserver(observer: self)
```

2. implement `CardReaderObserver` method according to your needs

```
extension UIViewController: CardReaderObserver {

    func didDiscover(peripherals: [CBPeripheral]) {
        // Discoverd peripherals
    }
    
    func didBluetoothConnected() {
        // Bluetooth connected, when attached to reader
    }
    
    func didBluetoothDisconnect() {
        // Bluetooth disconnected, error occurred or manually disconnect
    }
    
    func didBluetoothUpdateState(state: CBManagerState) {
        // Bluetooth state changed, see CBManagerState for more
    }
    
    func didCardRead(card: Card?, error: CardReaderError?) {
        // Card reader progress done, return card info if success, return error if fail
    }
    
    func didCardPresent() {
        // Card did present on NFC device
    }
    
    func didCardAbsent() {
        // Card did absent on NFC device
    }
}
```

3. Scan NFC Bluetooth device, see CardReaderObserver for more callbacks detail

```
CardReaderManager.shared.startBluetoothScan()
```

4. Connect a device after device found , see CardReaderObserver for more callbacks detail

```
CardReaderManager.shared.connectBluetooth(peripheral: peripheral)
```

5. If connect success, `didCardAbsent` will call if your card didn't present, now you present the card on the device, **get certificate information**, **verify certificate**, **verify device**, **verify blockchain** will automatically done in device. If verification pass, `didCardRead` will call and you can get all the card information including **address**, **face value**, **serial number** and further more.

6. GetRawTransaction before send a transaction, we provide `Bitcoin` and `Ethereum`

```
/// For Bitcoin
CardReaderManager.shared.getBtcRawTransaction(publicKey: publicKey, toAddress: toAddress, utxos: unspend, network: card.network, fee: fee) { (rawtx) in
	// use rawtx as parameter to send a transaction
	// sendRawTransaction(rawtx: rawtx), see NetworkManager for more
}
```

```
/// For Ethereum
CardReaderManager.shared.getEthRawTransaction(sendAddress: senderAddress, toAddress: toAddress, value: value, gasPrice: gasPrice, estimateGas: estimateGas, nonce: nonce) { (rawtx) in
	// use rawtx as parameter to send a transaction
	// sendRawTransaction(rawtx: rawtx), see NetworkManager for more
}
```

## NetworkManager

We provide most common API used in blockchain, you can just use `NetworkManager` singleton to use them, including below: 

- Universal
  - getBalance
  - sendRawTransaction
  - getTransactionReceipt
- Bitcoin
  - getUnspend
  - getEstimateFee
- Ethereum
  - getGasPrice
  - call
  - getNonce
  - getEstimateGas

**Pay attention** Before you make a request, you should better call `setNetwork` to config ApiKey, internal implement we use several third api to request, some api need api key, so you'd better config it even we provide default value, you can config it like this: 

```
let config = ApiKeyConfig(etherscanApiKeys: ["etherscanApiKey1", "etherscanApiKey2"], infuraApiKeys: ["infuraApiKey1", "infuraApiKey2", "infuraApiKey3"], blockcypherApiKeys: ["blockcypherApiKey1"])
NetworkManager.shared.setNetwork(config: config)
```

- Bitcoin request example

```
NetworkManager.shared.getBalance(blockchain: .bitcoin, network: .testnet, address: "address") { (balance, error) in
	guard error == nil else { 
		// error handle code will be here
		return 
	}
	// update UI for balance for example
    self.balanceLabel.text = balance
}
```

- Ethereum request example

```
NetworkManager.shared.getNonce(network: .kovan, address: "sendAddress") { (nonce, error) in
	guard error == nil else {
    	// error handle code will be here
        return
    }
    // store the nonce for example
    self.nonce = nonce
}
```

See `Example` or `eNotesSDK source code` to check all request usage

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## License

eNotesSDKPre is available under the MIT license. See the LICENSE file for more info.
