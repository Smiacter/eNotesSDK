//
//  ApiKeyConfig.swift
//  eNotesSDK
//
//  Created by Smiacter on 2018/10/10.
//

public struct ApiKeyConfig {
    var etherscanApiKeys: [String]
    var infuraApiKeys: [String]
    var blockcypherApiKeys: [String]
    
    public init(etherscanApiKeys: [String], infuraApiKeys: [String], blockcypherApiKeys: [String]) {
        self.etherscanApiKeys = etherscanApiKeys
        self.infuraApiKeys = infuraApiKeys
        self.blockcypherApiKeys = blockcypherApiKeys
    }
}
