//
//  NSString+GoogleDriver.h
//  GDSLink
//
//  Created by Hai Le on 4/11/18.
//  Copyright © 2018 Zaid Ameer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (GoogleDriver)

- (NSString*) googleDriverLink;
- (NSString*) htmlGoogleDriverLink;
- (BOOL) driverHasVideoStreamming;

@end
