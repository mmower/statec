//
//  StatecInitial.m
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecInitial.h"

@implementation StatecInitial

@synthesize name = _name;

- (id)initWithSyntaxTree:(CPSyntaxTree *)syntaxTree {
  self = [super init];
  if( self ) {
    NSAssert( 2 == [[syntaxTree children] count], @"StatecInitial must have exactly 2 children" );
    _name = [[[syntaxTree children] objectAtIndex:1] content];
  }
  return self;
}

@end
