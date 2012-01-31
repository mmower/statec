//
//  Machine.m
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecMachine.h"

@implementation StatecMachine

@synthesize name = _name;
@synthesize initialState = _initialState;
@synthesize states = _states;

- (id)initWithSyntaxTree:(CPSyntaxTree *)syntaxTree {
  self = [super init];
  if( self ) {
    NSArray *children = [syntaxTree children];
    _name = [[children objectAtIndex:1] content];
    _initialState = [[children objectAtIndex:3] name];
    _states = [children objectAtIndex:4];
  }
  return self;
}

@end
