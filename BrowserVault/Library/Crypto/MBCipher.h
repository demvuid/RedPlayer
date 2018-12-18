//
//  MBCipher.h
//  MustBin iOS
//
//  Created by Nate Mackey on 11/4/15.
//  Copyright © 2015 MustBin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

extern NSString * const MBCipherErrorDomain;

@interface MBCipher : NSObject

+ (instancetype)cipherForOperation:(CCOperation)operation
                    performPadding:(BOOL)performPadding
                               key:(NSData *)key
                                iv:(NSData *)iv
                             error:(NSError **)error;

- (NSData *)update:(NSData *)data andFinalize:(BOOL)finalize error:(NSError **)error;

@end
