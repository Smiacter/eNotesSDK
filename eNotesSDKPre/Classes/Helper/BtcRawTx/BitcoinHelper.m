//
//  BitcoinHelper.m
//  eNotesSDK
//
//  Created by Smiacter on 2018/10/12.
//

#import "BitcoinHelper.h"

@implementation BitcoinHelper

+ (NSData *)generateSignature: (NSString *)hexString hashtype: (BTCSignatureHashType)hashtype {
    NSLog(@"hexString: %@", hexString);
    NSString *rData=[hexString substringWithRange:NSMakeRange(0, 64)];
    NSString *sData=[hexString substringWithRange:NSMakeRange(64, 64)];
    BTCBigNumber *bigR=[[BTCBigNumber alloc] initWithHexString:rData];
    BTCBigNumber *bigS=[[BTCBigNumber alloc] initWithHexString:sData];
    BIGNUM *bigNR=bigR.BIGNUM;
    BIGNUM *bigNS=bigS.BIGNUM;
    ECDSA_SIG *sig=ECDSA_SIG_new();
    sig->r=bigNR;
    sig->s=bigNS;
    
    printf("(sig->r, sig->s): (%s,%s)\n", BN_bn2hex(sig->r), BN_bn2hex(sig->s));
    
    BN_CTX *ctx = BN_CTX_new();
    BN_CTX_start(ctx);
    
    EC_GROUP *group = EC_GROUP_new_by_curve_name(714);
    BIGNUM *order = BN_CTX_get(ctx);
    BIGNUM *halforder = BN_CTX_get(ctx);
    EC_GROUP_get_order(group, order, ctx);
    BN_rshift1(halforder, order);
    if (BN_cmp(sig->s, halforder) > 0) {
        // enforce low S values, by negating the value (modulo the order) if above order/2.
        BN_sub(sig->s, order, sig->s);
    }
    BN_CTX_end(ctx);
    BN_CTX_free(ctx);
    EC_GROUP_free(group);
    
    printf("(sig->r, sig->s): (%s,%s)\n", BN_bn2hex(sig->r), BN_bn2hex(sig->s));
    
    int sigSize=72;
    NSMutableData* signature = [NSMutableData dataWithLength:72 + 16]; // Make sure it is big enough
    
    unsigned char *pos = (unsigned char *)signature.mutableBytes;
    sigSize = i2d_ECDSA_SIG(sig, &pos);
    [signature setLength:sigSize];  // Shrink to fit actual size
    
    [signature appendBytes:&hashtype length:sizeof(hashtype)];
    
    return signature;
}

@end
