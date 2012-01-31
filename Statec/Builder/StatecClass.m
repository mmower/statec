//
//  SFClassModel.m
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecClass.h"

#import "StatecMethod.h"
#import "StatecProperty.h"
#import "StatecVariable.h"

@implementation StatecClass

@synthesize name = _name;
@synthesize baseClass = _baseClass;

@synthesize classDeclarations = _classDeclarations;
@synthesize headerImports = _headerImports;
@synthesize classImports = _classImports;

@synthesize initializers = _initializers;
@synthesize properties = _properties;
@synthesize variables = _variables;
@synthesize methods = _methods;


- (id)initWithName:(NSString *)name {
  self = [super init];
  if( self ) {
    _name = name;

    _classDeclarations = [NSMutableArray array];
    
    _headerImports = [NSMutableArray arrayWithObject:@"<Foundation/Foundation.h>"];
    _classImports = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%@.h",name]];
    
    _initializers = [NSMutableArray array];
    _properties = [NSMutableArray array];
    _variables = [NSMutableArray array];
    _methods = [NSMutableArray array];
  }
  return self;
}


- (void)addVariable:(StatecVariable *)variable {
  [[self variables] addObject:variable];
}


- (void)addMethod:(StatecMethod *)method {
  [[self methods] addObject:method];
}


- (NSString *)baseClassName {
  if( [self baseClass] ) {
    return [[self baseClass] name];
  } else {
    return @"NSObject";
  }
}


- (NSString *)instanceVariablesDeclarationString {
  NSMutableString *content = [NSMutableString string];
  
  for( StatecVariable *variable in [self variables] ) {
    if( [variable isInstanceScope] ) {
      [content appendString:[variable declarationString]];
    }
  }
  
  return content;
}


- (NSString *)instanceMethodsDeclarationString {
  NSMutableString *content = [NSMutableString string];
  
  for( StatecMethod *method in [self methods] ) {
    if( [method isInstanceScope] ) {
      [content appendString:[method declarationString]];
    }
  }
  
  return content;
}


- (NSString *)instanceMethodsDefinitionString {
  NSMutableString *content = [NSMutableString string];
  
  for( StatecMethod *method in [self methods] ) {
    if( [method isInstanceScope] ) {
      [content appendFormat:@"%@\n",[method definitionString]];
    }
  }
  
  return content;
}


- (NSString *)propertiesDeclarationString {
  NSMutableString *content = [NSMutableString string];
  
  for( StatecProperty *property in [self properties] ) {
    [content appendString:[property declarationString]];
  }
  
  return content;
}


- (NSString *)propertiesDefinitionString {
  NSMutableString *content = [NSMutableString string];
  
  for( StatecProperty *property in [self properties] ) {
    [content appendString:[property definitionString]];
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


- (NSString *)declarationString {
  NSMutableString *content = [NSMutableString string];
  
  [content appendString:[self importStatementString:[self headerImports]]];
  
  for( NSString *declaration in [self classDeclarations] ) {
    [content appendFormat:@"@class %@;",declaration];
  }
  [content appendString:@"\n"];
  
  [content appendFormat:@"@interface %@ : %@ {\n", [self name], [self baseClassName]];
  [content appendFormat:@"%@\n}\n", [self instanceVariablesDeclarationString]];
  [content appendFormat:@"%@\n", [self propertiesDeclarationString]];
  [content appendFormat:@"%@\n", [self instanceMethodsDeclarationString]];
  [content appendString:@"@end\n"];
  
  return content;
}


- (NSString *)definitionString {
  NSMutableString *content = [NSMutableString string];
  
  [content appendFormat:@"%@\n", [self importStatementString:[self classImports]]];
  
  [content appendFormat:@"@implementation %@\n", [self name], [self baseClassName]];
  
  [content appendFormat:@"%@\n", [self propertiesDefinitionString]];
  [content appendFormat:@"%@\n", [self instanceMethodsDefinitionString]];
  [content appendString:@"@end\n"];
  
  return content;
}


@end
