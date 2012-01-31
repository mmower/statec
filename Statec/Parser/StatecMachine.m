//
//  Machine.m
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecMachine.h"

#import "Statec.h"

@implementation StatecMachine

@synthesize name = _name;
@synthesize initialState = _initialState;
@synthesize states = _states;
@synthesize events = _events;

- (id)initWithSyntaxTree:(CPSyntaxTree *)syntaxTree {
  self = [super init];
  if( self ) {
    NSArray *children = [syntaxTree children];
    _name = [[children objectAtIndex:1] content];
    _initialState = [[children objectAtIndex:3] name];
    
    NSArray *stateList = [children objectAtIndex:4];
    
    _states = [NSMutableDictionary dictionary];
    for( StatecState *state in stateList ) {
      [_states setValue:state forKey:[state name]];
    }
    
    _events = [NSMutableDictionary dictionary];
    
    for( StatecState *state in stateList ) {
      for( StatecEvent *event in [state events] ) {
        
        NSMutableArray *transitionList = [_events objectForKey:[event name]];
        if( !transitionList ) {
          transitionList = [NSMutableArray array];
          [_events setValue:transitionList forKey:[event name]];
        }
        
        StatecTransition *transition = [[StatecTransition alloc] initWithSourceState:state targetState:[_states objectForKey:[event targetState]] viaEvent:event];
        [transitionList addObject:transition];
      }
    }
  }
  return self;
}




@end
