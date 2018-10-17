//
//  InfuraSendTxRequest.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/17.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

class InfuraSendTxRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        method = .post
        headers = ["Content-Type": "application/json"]
        parameterEncoding = JSONEncoding.default
    }
}
