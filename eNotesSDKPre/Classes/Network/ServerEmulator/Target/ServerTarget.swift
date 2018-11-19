//
//  ServerTarget.swift
//  eNotesSDKPre
//
//  Created by Smiacter on 2018/10/30.
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

import SolarNetwork

enum ServerMethod {
    case bleList
    case bleConnect(address: String)
    case apduTransmit(apdu: String, id: Int)
    
    var path: String {
        switch self {
        case .bleList:
            return "/bluetooth/list"
        case .bleConnect(let address):
            return "/bluetooth/connect?address=\(address)"
        case .apduTransmit:
            return "/card/transceive"
        }
    }
    
    var parameter: [String: Any]? {
        switch self {
        case .apduTransmit(let apdu, let id):
            return ["apdu": apdu, "id": id]
        default:
            return nil
        }
    }
}

struct ServerTarget: SLTarget {
    
    var baseURLString: String {
        let ip = CardReaderManager.shared.serverIp
        return "http://\(ip):8083/sdk"
    }
    
    var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutForRequest
        return config
    }
}
