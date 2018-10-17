//
//  UtxoOcModel.h
//  eNotes
//
//  Created by Smiacter on 2018/8/22.
//  Copyright © 2018 Smiacter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtxoOcModel : NSObject

@property NSString *txid;
@property UInt32 index;
@property NSString *script;
@property int64_t value;
@property UInt32 confirmations;
@property BOOL comfirmed;

- (instancetype)initWithTxid: (NSString *)txid index: (UInt32)index script: (NSString *)script value: (int64_t)value confirmations: (UInt32)confirmations comfirmed: (BOOL)comfirmed;

@end
