//
//  StatecCompilationUnit.m
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import "StatecCompilationUnit.h"

#import "Statec.h"

@implementation StatecCompilationUnit

@synthesize name = _name;
@synthesize comment = _comment;
@synthesize declarationImports = _declarationImports;
@synthesize definitionImports = _definitionImports;
@synthesize forwardDeclarations = _forwardDeclarations;
@synthesize variables = _variables;
@synthesize types = _types;
@synthesize classes = _classes;
@synthesize principalClass = _principalClass;


- (id)initWithName:(NSString *)name {
  self = [self init];
  if( self ) {
    _name = name;
    _comment = @"";
    _declarationImports = [NSMutableArray arrayWithObject:@"<Foundation/Foundation.h>"];
    _definitionImports = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%@.h",name]];
    _forwardDeclarations = [NSMutableArray array];
    _variables = [NSMutableArray array];
    _classes = [NSMutableArray array];
    _types = [NSMutableArray array];
  }
  return self;
}


- (void)addVariable:(StatecVariable *)variable {
  [_variables addObject:variable];
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


- (void)addForwardDeclaration:(NSString *)class {
  [[self forwardDeclarations] addObject:class];
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


- (NSString *)forwardDeclarationsString {
  NSMutableString *content = [NSMutableString string];
  
  for( NSString *class in [self forwardDeclarations] ) {
    [content appendFormat:@"@class %@;\n", class];
  }
  
  [content appendString:@"\n"];
  
  return content;
}


- (NSString *)variablesDeclarationString {
  NSMutableString *content = [NSMutableString string];
  for( StatecVariable *variable in [self variables] ) {
    if( [variable isGlobalScope] && ![variable isStaticScope] ) {
      [content appendString:[variable declarationString]];
    }
  }
  [content appendString:@"\n\n"];
  return content;
}


- (NSString *)variablesDefinitionString {
  NSMutableString *content = [NSMutableString string];
  for( StatecVariable *variable in [self variables] ) {
    if( [variable isGlobalScope] ) {
      [content appendString:[variable definitionString]];
    }
  }
  [content appendString:@"\n\n"];
  return content;
}


- (NSString *)declarationsString {
  NSMutableString *content = [NSMutableString string];
  
  if( ![[self comment] isEqualToString:@""] ) {
    [content appendFormat:@"%@\n\n", [self comment]];
  }
  
  [content appendString:[self importStatementString:[self declarationImports]]];
  [content appendString:[self forwardDeclarationsString]];
  
  [content appendString:[self variablesDeclarationString]];
  
  [content appendString:[self typeStatementString]];
  
  for( StatecClass *class in _classes ) {
    [content appendString:[class declarationString]];
  }
  [content appendString:@"\n"];
  
  return content;
}


- (NSString *)definitionsString {
  NSMutableString *content = [NSMutableString string];

  if( ![[self comment] isEqualToString:@""] ) {
    [content appendFormat:@"%@\n\n", [self comment]];
  }
  
  [content appendString:[self importStatementString:[self definitionImports]]];
  
  [content appendString:[self variablesDefinitionString]];
  
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
