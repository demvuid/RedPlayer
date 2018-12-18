//
//  MBCipher.m
//  MustBin iOS
//
//  Created by Nate Mackey on 11/4/15.
//  Copyright © 2015 MustBin Inc. All rights reserved.
//

#import "MBCipher.h"

NSString * const MBCipherErrorDomain = @"MBCipherErrorDomain";

@interface MBCipher ()

@property (nonatomic, assign) CCCryptorRef cryptor;

@end

@implementation MBCipher

+ (instancetype)cipherForOperation:(CCOperation)operation
                    performPadding:(BOOL)performPadding
                               key:(NSData *)key
                                iv:(NSData *)iv
                             error:(NSError *__autoreleasing *)error {
    
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus result;
    CCOptions options = performPadding? kCCOptionPKCS7Padding: 0;
    result = CCCryptorCreate(operation, kCCAlgorithmAES, options, key.bytes, key.length, iv.bytes, &cryptor);
    if (result != kCCSuccess || cryptor == NULL) {
        if (error) {
            *error = [NSError errorWithDomain:MBCipherErrorDomain code:result userInfo:nil];
        }
        NSAssert(NO, @"Could not create cryptor: %d", result);
        return nil;
    }
    return [[self alloc] initWithCryptor:cryptor];
}

- (instancetype)initWithCryptor:(CCCryptorRef)cryptor {
    if (self = [super init]) {
        _cryptor = cryptor;
    }
    return self;
}

- (void)dealloc {
    CCCryptorRelease(self.cryptor);
}

- (NSData *)update:(NSData *)data andFinalize:(BOOL)finalize error:(NSError **)error {
    size_t bufferSize = CCCryptorGetOutputLength(self.cryptor, data.length, finalize);
    NSMutableData *outputBuffer = [NSMutableData dataWithLength:bufferSize];
    uint8_t *outputBytes = outputBuffer.mutableBytes;
    size_t outputLength = 0;
    NSUInteger totalBytes = 0;
    CCCryptorStatus result = CCCryptorUpdate(self.cryptor, data.bytes, data.length, outputBytes, bufferSize,
                                             &outputLength);
    if (result != kCCSuccess) {
        if (error) {
            *error = [NSError errorWithDomain:MBCipherErrorDomain code:result userInfo:nil];
        }
        MBLog(@"Could not perform update: %d", result);
        return nil;
    }
    totalBytes = outputLength;
    
    if (finalize) {
        outputBytes += outputLength;
        bufferSize -= outputLength;
        result = CCCryptorFinal(self.cryptor, outputBytes, bufferSize, &outputLength);
        if (result != kCCSuccess) {
            if (error) {
                *error = [NSError errorWithDomain:MBCipherErrorDomain code:result userInfo:nil];
            }
            MBLog(@"Could not perform final: %d", result);
            return nil;
        }
        totalBytes += outputLength;
    }
    
    outputBuffer.length = totalBytes;
    return outputBuffer;
}

@end
