//
//  SFInstanceVariable.m
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecVariable.h"

@implementation StatecVariable

@synthesize scope = _scope;
@synthesize name = _name;
@synthesize type = _type;

- (id)initWithScope:(StatecScope)scope name:(NSString *)name type:(NSString *)type {
  self = [super init];
  if( self ) {
    _scope = scope;
    _name = name;
    _type = type;
  }
  return self;
}


- (BOOL)isInstanceScope {
  return ( _scope & StatecInstanceScope ) == StatecInstanceScope;
}


- (BOOL)isGlobalScope {
  return ( _scope & StatecGlobalScope ) == StatecGlobalScope;
}


- (BOOL)isStaticScope {
  return ( _scope & StatecStaticScope ) == StatecStaticScope;
}


- (NSString *)declarationString {
  if( [self isInstanceScope] ) {
    return [NSString stringWithFormat:@"\t%@ %@;\n", [self type], [self name]];
  } else {
    if( !(_scope & StatecStaticScope) ) {
      return [NSString stringWithFormat:@"extern %@ %@;", [self type], [self name]];
    } else {
      return @"";
    }
  }
}


- (NSString *)definitionString {
  if( [self isGlobalScope] ) {
    if( _scope & StatecStaticScope ) {
      return [NSString stringWithFormat:@"static %@ %@;\n", [self type], [self name]];
    } else {
      return [NSString stringWithFormat:@"%@ %@;\n", [self type], [self name]];
    }
  } else {
    return @"";
  }
}


@end
