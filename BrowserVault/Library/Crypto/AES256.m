//
//  AES256.m
//  MustBin iOS
//
//  Created by Satyender Mahajan on 2/19/13.
//  Copyright (c) 2013 MustBin Inc. All rights reserved.
//

#include <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import "AES256.h"

NSData *sha1(NSData *bytes)
{
    NSMutableData *_md = [NSMutableData dataWithLength:16];
    unsigned char *result = [_md mutableBytes];
    NSUInteger length = [bytes length];
    if (length > INT32_MAX) {
        MBLog("Warning: trying to hash bytes longer than the max CC_LONG value.  Length = %lu", (unsigned long)length);
    }
    if (result != CC_SHA1([bytes bytes], (CC_LONG)length, result)) {
        @throw [NSException exceptionWithName:@"SHA1Exception"
                                       reason:@"Unknown"
                                     userInfo:nil];
    }
    return _md;
}

NSData *sha256(NSData *bytes)
{
    NSMutableData *_md = [NSMutableData dataWithLength:32];
    unsigned char *result = [_md mutableBytes];
    NSUInteger length = [bytes length];
    if (length > INT32_MAX) {
        MBLog("Warning: trying to hash bytes longer than the max CC_LONG value.  Length = %lu", (unsigned long)length);
    }
    if (result != CC_SHA256([bytes bytes], (CC_LONG)length, result)) {
        @throw [NSException exceptionWithName:@"SHA256Exception"
                                       reason:@"Unknown"
                                     userInfo:nil];
    }
    return _md;
}

NSData *generateAES256KeyForString(NSString *string, NSData *salt)
{
    NSMutableData *derivedKey = [NSMutableData dataWithLength:kCCKeySizeAES256];
    
    const char * cStr = string.UTF8String;
    int result = CCKeyDerivationPBKDF(kCCPBKDF2, cStr, strlen(cStr), salt.bytes, salt.length, kCCPRFHmacAlgSHA1, 10000, derivedKey.mutableBytes, derivedKey.length);
    
    NSCAssert(result == kCCSuccess, @"Unable to create AES key for string: %d", result);
    return derivedKey;
}

NSData *encryptUsingAES256(NSData *data, NSData *key,NSData* iv)
{
    return cipher(key,data,iv,kCCEncrypt,kCCOptionPKCS7Padding,nil);
}

NSData *decryptUsingAES256(NSData *data, NSData *key,NSData* iv, NSMutableData* contents)
{
    return cipher(key,data,iv,kCCDecrypt,kCCOptionPKCS7Padding,contents);
}

NSData *cipher(NSData *key, NSData *value, NSData *iv, CCOperation operation, CCOptions options, NSMutableData *output)
{
    // SHA256 the key unless it's already 256 bits.
    if (kCCKeySizeAES256 != [key length]) {
        key = sha256(key);
    }
    
    NSUInteger len = [value length];
    NSUInteger capacity = (len / kCCBlockSizeAES128 + 1) * kCCBlockSizeAES128;
    NSMutableData *data;
    if (nil == output) {
        data = [NSMutableData dataWithLength:capacity];
    } else {
        data = output;
        if ([data length] < capacity) {
            [data setLength:capacity];
        }
    }
    
    const void *_iv = [iv bytes];
    
    size_t dataOutMoved;
    CCCryptorStatus ccStatus = CCCrypt(operation, kCCAlgorithmAES128, options, (const char*) [key bytes], [key length], _iv, (const void *) [value bytes], [value length], (void *)[data mutableBytes], capacity, &dataOutMoved);
    
    if (dataOutMoved < [data length]) {
        [data setLength:dataOutMoved];
    }
    
    if(ccStatus == kCCSuccess) {
        return data;
    }
    
    if(output == nil) {
        [data setLength:0];
        data = nil;
    }
    switch (ccStatus) {
        case kCCParamError:
            @throw [NSException exceptionWithName:@"IllegalParameterValueException"
                                           reason:@"Illegal parameter value."
                                         userInfo:nil];
            break;
        case kCCBufferTooSmall:
            MBLog(@"AES: InsufficentBufferException");
            break;
        case kCCMemoryFailure:
            MBLog(@"AES: MemoryAllocationFailure");
            break;
        case kCCAlignmentError:
            MBLog(@"AES: InputAlignmentException: Input size was not aligned properly");
            break;
        case kCCDecodeError:
            MBLog(@"AES: DecryptionException");
            break;
        case kCCUnimplemented:
            @throw [NSException exceptionWithName:@"FunctionNotImplementedException"
                                           reason:@"Function not implemented for the current algorithm."
                                         userInfo:nil];
            break;
    }
    return nil;
}

// Generate secure random bytes for salt, IVs, and keys.
NSData * generateRandomData(unsigned int len)
{
    assert(len > 0);
    NSMutableData* data = [NSMutableData dataWithLength:len];
    int result = SecRandomCopyBytes(kSecRandomDefault,len,data.mutableBytes);
    assert(result == 0);
    return data;
}



