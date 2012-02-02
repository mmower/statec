//
//  StatecTransition.m
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import "StatecTransition.h"

#import "Statec.h"

@implementation StatecTransition

@synthesize sourceState = _sourceState;
@synthesize targetState = _targetState;

- (id)initWithSourceState:(StatecState *)sourceState targetState:(StatecState *)targetState {
  self = [super init];
  if( self ) {
    _sourceState = sourceState;
    _targetState = targetState;
  }
  return self;
}


@end
