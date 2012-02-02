//
//  NSString+StatecExtensions.m
//  Statec
//
//  Created by Matt Mower on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+StatecExtensions.h"

@implementation NSString (StatecExtensions)

- (NSString *)statecStringByCapitalisingFirstLetter {
  return [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] capitalizedString]];
}


- (NSString *)statecStringByLoweringFirstLetter {
  return [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] lowercaseString]];
}


@end
