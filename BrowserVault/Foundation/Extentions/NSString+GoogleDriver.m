//
//  NSString+GoogleDriver.m
//  GDSLink
//
//  Created by Hai Le on 4/11/18.
//  Copyright © 2018 Zaid Ameer. All rights reserved.
//

#import "NSString+GoogleDriver.h"

@implementation NSString (GoogleDriver)

- (NSString*) googleDriverLink
{
    NSURL* myURL = [NSURL URLWithString:self];
    if (myURL) {
        NSString* myHTMLString = [[NSString alloc] initWithContentsOfURL:myURL encoding:NSUTF8StringEncoding error:nil];
        return [myHTMLString htmlGoogleDriverLink];
    }
    return self;
}

- (BOOL) driverHasVideoStreamming
{
    NSRange range = [self rangeOfString:@"[\"fmt_stream_map\"" options:NSBackwardsSearch];
    return range.location != NSNotFound;
}

- (NSString*) htmlGoogleDriverLink
{
    NSRange range = [self rangeOfString:@"[\"fmt_stream_map\"" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSString* firstString = [self substringFromIndex:range.location + range.length + 1];
        if (firstString) {
            NSRange rangeSecond = [firstString rangeOfString:@",[\"url_encoded_fmt_stream_map\"" options:NSBackwardsSearch];
            if (rangeSecond.location != NSNotFound) {
                NSString* secondString = [firstString substringToIndex:rangeSecond.location - 1];
                secondString = [secondString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                secondString = [secondString stringByReplacingOccurrencesOfString:@"]" withString:@""];
                secondString = [secondString stringByReplacingOccurrencesOfString:@",35" withString:@""];
                
                NSArray* deURL = [secondString componentsSeparatedByString:@","];
                
                if (deURL != nil && [deURL count] > 0) {
                    NSArray* theLinkHash = [[deURL lastObject] componentsSeparatedByString:@"|"];
                    if ([theLinkHash count]) {
                        NSString* theLink = [theLinkHash lastObject];
                        theLink = [theLink stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                        theLink = [theLink stringByReplacingOccurrencesOfString:@"%5Cu" withString:@""];
                        theLink = [theLink stringByReplacingOccurrencesOfString:@"003d" withString:@"="];
                        theLink = [theLink stringByReplacingOccurrencesOfString:@"0026" withString:@"&"];
                        theLink = [theLink stringByReplacingOccurrencesOfString:@"%252C" withString:@","];
                        return theLink;
                    }
                }
            }
        }
    }
    return self;
}
@end
