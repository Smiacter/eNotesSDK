//
//  BitcoinHelper.h
//  eNotesSDK
//
//  Created by Smiacter on 2018/10/12.
//

#import <Foundation/Foundation.h>
#import "BTCBigNumber.h"
#import "BTCSignatureHashType.h"
#import "ecdsa.h"

NS_ASSUME_NONNULL_BEGIN

@interface BitcoinHelper : NSObject

+ (NSData *)generateSignature: (NSString *)hexString hashtype: (BTCSignatureHashType)hashtype;

@end

NS_ASSUME_NONNULL_END
