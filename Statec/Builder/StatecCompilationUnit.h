//
//  StatecCompilationUnit.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StatecType;
@class StatecClass;
@class StatecVariable;

@interface StatecCompilationUnit : NSObject

@property (strong) NSString *name;
@property (strong) NSString *comment;
@property (strong) NSMutableArray *declarationImports;
@property (strong) NSMutableArray *definitionImports;
@property (strong) NSMutableArray *forwardDeclarations;
@property (strong) NSMutableArray *variables;
@property (strong) NSMutableArray *types;
@property (strong) NSMutableArray *classes;
@property (strong) StatecClass *principalClass;

- (id)initWithName:(NSString *)name;

- (void)addDeclarationImport:(NSString *)import;
- (void)addDefinitionImport:(NSString *)import;
- (void)addForwardDeclaration:(NSString *)class;
- (void)addVariable:(StatecVariable *)variable;
- (void)addClass:(StatecClass *)class;
- (void)addType:(StatecType *)type;

- (NSString *)headerFileName;
- (NSString *)classFileName;

- (BOOL)writeDefinitions:(NSString *)path error:(NSError **)error;
- (BOOL)writeDeclarations:(NSString *)path error:(NSError **)error;
- (BOOL)writeFilesTo:(NSString *)folder error:(NSError **)error;

@end
