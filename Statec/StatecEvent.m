//
//  StatecEvent.m
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import "StatecEvent.h"

#import "NSString+StatecExtensions.h"

@implementation StatecEvent

@synthesize name = _name;
@synthesize targetState = _targetState;
@synthesize transitions = _transitions;


- (id)init {
  self = [super init];
  if( self ) {
    _transitions = [NSMutableArray array];
  }
  return self;
}


- (id)initWithSyntaxTree:(CPSyntaxTree *)syntaxTree {
  self = [self init];
  if( self ) {
    NSAssert( 4 == [[syntaxTree children] count], @"StatecEvent must have exactly 4 children" );
    _name = [[[syntaxTree children] objectAtIndex:1] content];
    _targetState = [[[syntaxTree children] objectAtIndex:3] content];
  }
  return self;
}


- (NSString *)callbackMethodName {
  return [NSString stringWithFormat:@"%@Event", [[self name] statecStringByLoweringFirstLetter]];
}


- (NSString *)internalCallbackMethodName {
  return [NSString stringWithFormat:@"%@EventFromMachine:", [[self name] statecStringByLoweringFirstLetter]];
}


@end
