//
//  StatecState.m
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import "StatecState.h"

#import "StatecEnter.h"
#import "StatecExit.h"
#import "StatecEvent.h"

@implementation StatecState

@synthesize name = _name;
@synthesize wantsEnter = _wantsEnter;
@synthesize wantsExit = _wantsExit;
@synthesize events = _events;

- (id)initWithSyntaxTree:(CPSyntaxTree *)syntaxTree {
  self = [super init];
  if( self ) {
    NSArray *children = [syntaxTree children];
    
    _name = [[children objectAtIndex:1] content];
    
    NSArray *enter = [children objectAtIndex:3];
    if( [enter count] > 0 && [[enter objectAtIndex:0] isKindOfClass:[StatecEnter class]] ) {
      _wantsEnter = YES;
    } else {
      _wantsEnter = NO;
    }
    
    NSArray *exit = [children objectAtIndex:4];
    if( [exit count] > 0 && [[exit objectAtIndex:0] isKindOfClass:[StatecExit class]] ) {
      _wantsExit = YES;
    } else {
      _wantsExit = NO;
    }
    
    _events = [children objectAtIndex:5];
  }
  return self;
}

- (BOOL)respondsToEventName:(NSString *)eventName {
  for( StatecEvent *event in [self events] ) {
    if( [[event name] isEqualToString:eventName] ) {
      return YES;
    }
  }
  
  return NO;
}

@end
