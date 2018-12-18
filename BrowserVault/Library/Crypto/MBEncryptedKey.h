//
//  MBEncryptedKey.h
//  MustBin iOS
//
//  Created by Nate Mackey on 12/22/14.
//  Copyright (c) 2014 MustBin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBEncryptedKey : NSObject

@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSData *encryptedKey;

- (instancetype)initEncryptedKey:(NSData *)encryptedKey withUuid:(NSString *)uuid NS_DESIGNATED_INITIALIZER;

@end
