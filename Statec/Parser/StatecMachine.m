//
//  Machine.m
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
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
    
    NSArray *stateList = [children objectAtIndex:4];
    
    _states = [NSMutableDictionary dictionary];
    for( StatecState *state in stateList ) {
      [_states setValue:state forKey:[state name]];
    }
    
    _initialState = [_states objectForKey:[[children objectAtIndex:3] name]];
    
    _events = [NSMutableDictionary dictionary];
    
    for( StatecState *state in stateList ) {
      for( StatecEvent *event in [state events] ) {
        
        StatecEvent *globalEvent = [_events objectForKey:[event name]];
        if( !globalEvent ) {
          globalEvent = event;
          [_events setValue:globalEvent forKey:[event name]];
        }
        
//        NSMutableArray *transitionList = [_events objectForKey:[event name]];
//        if( !transitionList ) {
//          transitionList = [NSMutableArray array];
//          [_events setValue:transitionList forKey:[event name]];
//        }
        
        StatecTransition *transition = [[StatecTransition alloc] initWithSourceState:state targetState:[_states objectForKey:[event targetState]]];
        [[globalEvent transitions] addObject:transition];
//        [transitionList addObject:transition];
      }
    }
  }
  return self;
}


- (NSArray *)validatesInitialStateIsDefined {
  for( StatecState *state in [[self states] allValues] ) {
    if( [[state name] isEqualToString:[[self initialState] name]] ) {
      return [NSArray array];
    }
  }
  
  return [NSArray arrayWithObject:[NSString stringWithFormat:@"Initial state '%@' is not defined as a state", _initialState]];
}


- (NSArray *)validatesEventTransitions {
  NSMutableArray *issues = [NSMutableArray array];
  
  for( StatecEvent *event in [[self events] allValues] ) {
    for( StatecTransition *transition in [event transitions] ) {
      NSSet *matching = [[self states] keysOfEntriesPassingTest:^BOOL(id key, id state, BOOL *stop) {
        return [[state name] isEqualToString:[[transition targetState] name]];
      }];
      
      if( [matching count] < 1 ) {
        [issues addObject:[NSString stringWithFormat:@"State '%@' declares event '%@' should transition to non-existent state", [[transition sourceState] name], [event name]]];
      }
    }
  }
  
  return issues;
}


- (BOOL)isMachineValid:(NSArray **)issues {
  NSMutableArray *issueList = [NSMutableArray array];
  [issueList addObjectsFromArray:[self validatesInitialStateIsDefined]];
  [issueList addObjectsFromArray:[self validatesEventTransitions]];
  if( [issueList count] > 0 ) {
    *issues = issueList;
    NSLog( @"INVALID MACHINE" );
    return NO;
  } else {
    NSLog( @"VALID MACHINE" );
    return YES;
  }
}




@end
