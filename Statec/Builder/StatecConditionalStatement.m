//
//  StatecConditionalStatement.m
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import "StatecConditionalStatement.h"

@implementation StatecConditionalStatement

@synthesize condition = _condition;
@synthesize ifTrue = _ifTrue;
@synthesize ifFalse = _ifFalse;

- (id)initWithCondition:(NSString *)condition {
  self = [self init];
  if( self ) {
    _condition = condition;
  }
  return self;
}


- (NSString *)statementString {
  NSMutableString *content = [NSMutableString string];
  
  [content appendFormat:@"if( ( %@ ) )", [self condition]];
  [content appendString:[[self ifTrue] statementString]];
  if( _ifFalse ) {
    [content appendString:@" else "];
    [content appendString:[[self ifFalse] statementString]];
  }
  
  return content;
}

@end
