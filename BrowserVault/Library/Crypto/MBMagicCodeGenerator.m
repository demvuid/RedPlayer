//
//  MBMagicCode.m
//  MustBin iOS
//
//  Created by Nate Mackey on 6/11/15.
//  Copyright (c) 2015 MustBin Inc. All rights reserved.
//

#import "MBMagicCodeGenerator.h"

@implementation MBMagicCodeGenerator

+ (MBMagicCodeGenerator *)sharedMagicCodeGenerator {
    static MBMagicCodeGenerator *sharedGenerator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGenerator = [MBMagicCodeGenerator new];
    });
    return sharedGenerator;
}

- (NSString *)alphaNumericCodeWithLength:(NSUInteger)length {
    NSMutableString *code = [[NSMutableString alloc] initWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        u_int32_t d = arc4random_uniform(36);
        if (d < 10) {
            // 0 - 9 should be used as numbers
            [code appendString:[NSString stringWithFormat:@"%d", d]];
        } else {
            // Convert 10 - 36 into A - Z
            d = d - 10 + 'A';
            [code appendString:[NSString stringWithFormat:@"%c", d]];
        }
    }
    return code;
}

- (NSString *)alphaCodeWithLength:(NSUInteger)length {
    NSMutableString *code = [[NSMutableString alloc] initWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        u_int32_t d = arc4random_uniform(26);
        [code appendString:[NSString stringWithFormat:@"%c", d + 'A']];
    }
    return code;
}

- (NSString *)numericCodeWithLength:(NSUInteger)length {
    NSMutableString *code = [[NSMutableString alloc] initWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        u_int32_t d = arc4random_uniform(10);
        [code appendString:[NSString stringWithFormat:@"%d", d]];
    }
    return code;
}

@end
