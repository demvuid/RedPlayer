//
//  AES256.h
//  MustBin iOS
//
//  Created by Satyender Mahajan on 2/19/13.
//  Copyright (c) 2013 MustBin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

NSData *sha1(NSData *bytes);
NSData *sha256(NSData *bytes);
NSData *generateAES256KeyForString(NSString *string, NSData *salt);
NSData *encryptUsingAES256(NSData *bytes, NSData *key,NSData* iv);
NSData *decryptUsingAES256(NSData *bytes, NSData *key,NSData* iv,NSMutableData* contents);
NSData *cipher(NSData *key, NSData *value, NSData *iv, CCOperation operation, CCOptions options, NSMutableData *output);
NSData *generateRandomData(unsigned int len);
NSString *base64Encode(NSData* bytes);
NSData* base64Decode(NSData* encoded);
