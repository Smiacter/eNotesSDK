//
//  InfuraCallRequest.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/14.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

class InfuraCallRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        method = .post
        headers = ["Content-Type": "application/json"]
        parameterEncoding = JSONEncoding.default
    }
    
//    let jsonrpc = JsonRpcVersion
//    let method = "eth_call"
//    let id = InfuraId
//    var params: [Any] = []
}
