//
//  eNotesArrayPostRequest.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/16.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

class eNotesArrayPostRequest: SLRequest {
    
    override func loadRequest() {
        super.loadRequest()
        
        method = .post
        headers = ["Content-Type": "application/json"]
        parameterEncoding = SLParameterValueJSONEncoding.default
    }
    
    var anyKey: [Any] = []
}
