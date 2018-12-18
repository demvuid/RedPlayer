//
//  MBEncryptedKey.m
//  MustBin iOS
//
//  Created by Nate Mackey on 12/22/14.
//  Copyright (c) 2014 MustBin Inc. All rights reserved.
//

#import "MBEncryptedKey.h"

@implementation MBEncryptedKey

- (instancetype)init {
    self = [self initEncryptedKey:nil withUuid:nil];
    return self;
}

- (instancetype)initEncryptedKey:(NSData *)encryptedKey withUuid:(NSString *)uuid {
    if (self = [super init]) {
        _uuid = uuid;
        _encryptedKey = encryptedKey;
    }
    return self;
}

@end
