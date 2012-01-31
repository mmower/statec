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
@synthesize declarationImports = _declarationImports;
@synthesize definitionImports = _definitionImports;
@synthesize types = _types;
@synthesize classes = _classes;


- (id)initWithName:(NSString *)name {
  self = [self init];
  if( self ) {
    _name = name;
    _declarationImports = [NSMutableArray arrayWithObject:@"<Foundation/Foundation.h>"];
    _definitionImports = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%@.h",name]];
    _classes = [NSMutableArray array];
    _types = [NSMutableArray array];
  }
  return self;
}


- (void)addClass:(StatecClass *)class {
  [_classes addObject:class];
}


- (void)addType:(StatecType *)type {
  [_types addObject:type];
}


- (void)addDeclarationImport:(NSString *)import {
  [[self declarationImports] addObject:import];
}


- (void)addDefinitionImport:(NSString *)import {
  [[self definitionImports] addObject:import];
}


- (NSString *)headerFileName {
  return [NSString stringWithFormat:@"%@.h",[self name]];
}


- (NSString *)classFileName {
  return [NSString stringWithFormat:@"%@.m",[self name]];
}


- (NSString *)typeStatementString {
  NSMutableString *content = [NSMutableString string];
  for( StatecType *type in [self types] ) {
    [content appendString:[type statementString]];
  }
  
  return content;
}


- (NSString *)importStatementString:(NSArray *)imports {
  NSMutableString *content = [NSMutableString string];
  
  for( NSString *import in imports ) {
    if( [import hasPrefix:@"<"] ) {
      [content appendFormat:@"#import %@\n",import];
    } else {
      [content appendFormat:@"#import \"%@\"\n",import];
    }
    [content appendString:@"\n"];
  }
  
  return content;
}


- (NSString *)declarationsString {
  NSMutableString *content = [NSMutableString string];
  
  [content appendString:[self importStatementString:[self declarationImports]]];
  
  [content appendString:[self typeStatementString]];
  
  for( StatecClass *class in _classes ) {
    [content appendString:[class declarationString]];
  }
  [content appendString:@"\n"];
  
  return content;
}


- (NSString *)definitionsString {
  NSMutableString *content = [NSMutableString string];
  
  [content appendString:[self importStatementString:[self definitionImports]]];
  
  for( StatecClass *class in [self classes] ) {
    [content appendString:[class definitionString]];
  }
  [content appendString:@"\n"];
  
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
