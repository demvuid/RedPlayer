//
//  NSString+AES.m
//  VideoPlayer
//
//  Created by Hai Le on 4/10/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

#import "NSString+AES.h"
#import "NSString+Base64.h"
#import "NSData+AES.h"

#define AES_KEY @"cdapanh123nfhtl1gacp154(@99430nr"

@implementation NSString (AES)

- (NSString *) decryptAESString {
    NSData *cipherData = [self base64DecodedData];
    NSData *cipherDecryptData = [cipherData AES256DecryptWithKey:AES_KEY];
    NSString* cipherDecryptString = [[NSString alloc] initWithData:cipherDecryptData encoding:NSASCIIStringEncoding];
    cipherDecryptString = [cipherDecryptString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cipherDecryptString = [cipherDecryptString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\""]];
    cipherDecryptString = [cipherDecryptString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    return cipherDecryptString;
}
@end
