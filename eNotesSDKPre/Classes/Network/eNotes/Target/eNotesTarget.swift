//
//  eNotesTarget.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/13.
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
