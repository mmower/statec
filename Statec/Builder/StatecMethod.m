//
//  SFClassMethod.m
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecMethod.h"

@implementation StatecMethod

@synthesize scope = _scope;
@synthesize returnType = _returnType;
@synthesize selector = _selector;
@synthesize body = _body;
@synthesize arguments = _arguments;


- (id)init {
  self = [super init];
  if( self ) {
    _arguments = [NSMutableArray array];
    _body = [[StatecStatementGroup alloc] init];
  }
  return self;
}


- (id)initWithScope:(StatecScope)scope returnType:(NSString *)returnType selector:(SEL)selector {
  self = [self init];
  if( self ) {
    _scope = scope;
    _returnType = returnType;
    _selector = selector;
  }
  return self;
}


- (void)addArgument:(StatecArgument *)argument {
  [[self arguments] addObject:argument];
}


- (BOOL)isInstanceScope {
  return StatecInstanceScope == _scope;
}


- (BOOL)isClassScope {
  return StaticClassScope == _scope;
}


- (NSString *)scopeString {
  if( [self isInstanceScope] ) {
    return @"-";
  } else {
    return @"+";
  }
}


- (NSString *)selectorString {
  return NSStringFromSelector( [self selector] );
}


- (NSString *)signatuareString {
  NSMutableString *content = [NSMutableString string];
  
  [content appendString:[self scopeString]];
  [content appendString:@" ("];
  [content appendString:[self returnType]];
  [content appendString:@")"];
  
  NSRange range = [[self selectorString] rangeOfString:@":"];
  if( range.location == NSNotFound ) {
    [content appendString:[self selectorString]];
  } else {
    
    NSArray *selectorComponents = [[self selectorString] componentsSeparatedByString:@":"];
    if( [[selectorComponents objectAtIndex:[selectorComponents count]-1] isEqualToString:@""] ) {
      selectorComponents = [selectorComponents subarrayWithRange:NSMakeRange(0,[selectorComponents count]-1)];
    }
    
    int componentIndex = 0;
    for( NSString *component in selectorComponents ) {
      if( componentIndex > 0 ) {
        [content appendString:@" "];
      }
      
      [content appendFormat:@"%@:%@",component,[[[self arguments] objectAtIndex:componentIndex] argumentString]];
      
      componentIndex += 1;
    }
  }
  
  return content;
}


- (NSString *)declarationString {
  return [NSString stringWithFormat:@"%@;\n",[self signatuareString]];
}


- (NSString *)definitionString {
  return [NSString stringWithFormat:@"%@ %@\n",[self signatuareString],[[self body] statementString]];
}


@end
