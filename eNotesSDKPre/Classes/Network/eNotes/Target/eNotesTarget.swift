//
//  eNotesTarget.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/13.
//  Copyright © 2018 Smiacter. All rights reserved.
//

import SolarNetwork

struct eNotesTarget: SLTarget {
    var baseURLString: String {
        return "https://api.enotes.io:8443/v1"
    }
    
    var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutForRequest
        return config
    }
    
    var serverTrustPolicies: [String : ServerTrustPolicy]? {
        
        #if DEBUG
        let validateCertificateChain = false
        let validateHost = false
        #else
        let validateCertificateChain = true
        let validateHost = true
        #endif
        
        let policies: [String: ServerTrustPolicy] = [
            host: .pinCertificates(
                certificates: ServerTrustPolicy.certificates(),
                validateCertificateChain: validateCertificateChain,
                validateHost: validateHost
            )
        ]
        return policies
    }
    
    var clientTrustPolicy: (secPKCS12Name: String, password: String)? {
        return (secPKCS12Name: "client", password: "123456")
    }
}
