//
//  StatecEnumeration.m
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import "StatecEnumeration.h"

@implementation StatecEnumeration

- (id)init {
  self = [super init];
  if( self ) {
    _elements = [NSMutableArray array];
  }
  return self;
}


- (void)addElement:(NSString *)element {
  [_elements addObject:element];
}


- (NSString *)statementString {
  NSMutableString *content = [NSMutableString string];
  
  if( [self name] ) {
    [content appendFormat:@"enum %@ {\n",[self name]];
  } else {
    [content appendString:@"enum {\n"];
  }
  
  for( NSString *element in _elements ) {
    [content appendFormat:@"\t%@,\n",element];
  }
  
  [content deleteCharactersInRange:NSMakeRange( [content length]-2, 2 )];
  
  [content appendString:@"\n}"];
  
  return content;
}




@end
