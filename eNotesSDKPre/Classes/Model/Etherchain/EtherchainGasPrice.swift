//
//  EtherchainGasPrice.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/14.
//  Copyright © 2018 Smiacter. All rights reserved.
//

public struct EtherchainGasPrice: Decodable {
    public var safeLow: String
    public var standard: String
    public var fast: String
    public var fastest: String
}
