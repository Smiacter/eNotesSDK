//
//  UtxoOcModel.m
//  eNotes
//
//  Created by Smiacter on 2018/8/22.
//  Copyright © 2018 Smiacter. All rights reserved.
//

#import "UtxoOcModel.h"

@implementation UtxoOcModel

- (instancetype)initWithTxid: (NSString *)txid index: (UInt32)index script: (NSString *)script value: (int64_t)value confirmations: (UInt32)confirmations comfirmed: (BOOL)comfirmed {
    self = [super init];
    if (self) {
        self.txid = txid;
        self.index = index;
        self.script = script;
        self.value = value;
        self.confirmations = confirmations;
        self.comfirmed = comfirmed;
    }
    
    return self;
}

@end
