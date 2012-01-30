//
//  CPToken.h
//  CoreParse
//
//  Created by Tom Davie on 12/02/2011.
//  Copyright 2011 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The CPToken class reperesents a token in the token stream.
 * 
 * All tokens respond to the -name message which is used to identify the token while parsing.
 *
 * CPToken is an abstract class.  CPTokenRegnisers should add instances of CPTokens concrete subclasses to their token stream.
 */
@interface CPToken : NSObject

/**
 * The token name.
 */
@property (readonly) NSString *name;

@end
