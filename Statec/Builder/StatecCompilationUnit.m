//
//  StatecCompilationUnit.m
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecCompilationUnit.h"

#import "Statec.h"

@implementation StatecCompilationUnit

@synthesize name = _name;
@synthesize types = _types;
@synthesize classes = _classes;


- (id)initWithName:(NSString *)name {
  self = [super init];
  if( self ) {
    _name = name;
  }
  return self;
}


- (void)addClass:(StatecClass *)class {
  [_classes addObject:class];
}


- (NSString *)headerFileName {
  return [NSString stringWithFormat:@"%@.h",[self name]];
}


- (NSString *)classFileName {
  return [NSString stringWithFormat:@"%@.m",[self name]];
}


- (NSString *)declarationsString {
  NSMutableString *content = [NSMutableString string];
  
  for( StatecClass *class in _classes ) {
    [content appendString:[class declarationString]];
  }
  [content appendString:@"\n"];
  
  return content;
}


- (NSString *)definitionsString {
  NSMutableString *content = [NSMutableString string];
  
  return content;
}


- (BOOL)writeDefinitions:(NSString *)path error:(NSError **)error {
  return [[self definitionsString] writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:error];
}


- (BOOL)writeDeclarations:(NSString *)path error:(NSError **)error {
  return [[self declarationsString] writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:error];
}


- (BOOL)writeFilesTo:(NSString *)folder error:(NSError **)error {
  if( ![self writeDeclarations:[folder stringByAppendingPathComponent:[self headerFileName]] error:error] ) {
    return NO;
  }
  if( ![self writeDefinitions:[folder stringByAppendingPathComponent:[self classFileName]] error:error] ) {
    return NO;
  }
  
  return YES;
}


@end
