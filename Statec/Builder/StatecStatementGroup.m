//
//  StatecStatementGroup.m
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecStatementGroup.h"

#import "Statec.h"

@implementation StatecStatementGroup

@synthesize statements = _statements;


+ (StatecStatementGroup *)group {
  return [[StatecStatementGroup alloc] init];
}

- (id)init {
  self = [super init];
  if( self ) {
    _statements = [[NSMutableArray alloc] init];
  }
  return self;
}


- (id)initWithBody:(NSString *)body {
  self = [self init];
  if( self ) {
    [self addStatement:[[StatecCodeStatement alloc] initWithBody:body]];
  }
  return self;
}


- (id)initWithStatement:(StatecStatement *)statement {
  self = [self init];
  if( self ) {
    [self addStatement:statement];
  }
  return self;
}


- (void)append:(NSString *)format, ... {
  va_list args;
  va_start( args, format );
  NSMutableString *content = [NSMutableString string];
  CFStringAppendFormatAndArguments( (__bridge CFMutableStringRef)content, nil, (__bridge CFStringRef)format, args );
  [[self statements] addObject:content];
}


//- (void)addLine:(NSString *)line {
//  [[self statements] addObject:line];
//}


- (void)addStatement:(StatecStatement *)statement {
  [[self statements] addObject:statement];
}


- (NSString *)statementString {
  NSMutableString *content = [NSMutableString string];
  
  [content appendString:@"{\n"];
  for( id statement in [self statements] ) {
    if( [statement isKindOfClass:[StatecStatement class]] ) {
      [content appendString:[statement statementString]];
    } else {
      [content appendFormat:@"%@\n",statement];
    }
  }
  [content appendString:@"}\n"];
  
  return content;
}


@end
