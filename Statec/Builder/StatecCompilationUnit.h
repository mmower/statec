//
//  StatecCompilationUnit.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatecCompilationUnit : NSObject

@property (strong) NSString *name;
@property (strong) NSMutableArray *types;
@property (strong) NSMutableArray *classes;

- (id)initWithName:(NSString *)name;

- (BOOL)writeDefinitions:(NSString *)path error:(NSError **)error;
- (BOOL)writeDeclarations:(NSString *)path error:(NSError **)error;
- (BOOL)writeFilesTo:(NSString *)folder error:(NSError **)error;

@end
