//
//  SFClassModel.h
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StatecMethod;
@class StatecVariable;

@interface StatecClass : NSObject

@property (strong) NSString *name;
@property (strong) StatecClass *baseClass;

@property (strong) NSMutableArray *initializers;
@property (strong) NSMutableArray *properties;
@property (strong) NSMutableArray *variables;
@property (strong) NSMutableArray *methods;

@property (strong) NSMutableArray *classDeclarations;
@property (strong) NSMutableArray *headerImports;
@property (strong) NSMutableArray *classImports;

- (id)initWithName:(NSString *)name;

- (void)addVariable:(StatecVariable *)variable;
- (void)addMethod:(StatecMethod *)method;


- (NSString *)declarationString;
- (NSString *)definitionString;

@end
