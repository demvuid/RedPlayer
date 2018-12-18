//
//  MBMagicCode.h
//  MustBin iOS
//
//  Created by Nate Mackey on 6/11/15.
//  Copyright (c) 2015 MustBin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBMagicCodeGenerator : NSObject

+ (MBMagicCodeGenerator *)sharedMagicCodeGenerator;

- (NSString *)alphaNumericCodeWithLength:(NSUInteger)length;
- (NSString *)alphaCodeWithLength:(NSUInteger)length;
- (NSString *)numericCodeWithLength:(NSUInteger)length;

@end
