//
//  StatecEvent.m
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecEvent.h"

@implementation StatecEvent

@synthesize name = _name;
@synthesize targetState = _targetState;

- (id)initWithSyntaxTree:(CPSyntaxTree *)syntaxTree {
  self = [super init];
  if( self ) {
    NSAssert( 4 == [[syntaxTree children] count], @"StatecEvent must have exactly 4 children" );
    _name = [[[syntaxTree children] objectAtIndex:1] content];
    _targetState = [[[syntaxTree children] objectAtIndex:3] content];
  }
  return self;
}


@end
