//
//  SFClassMethod.h
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Statec.h"

@class StatecArgument;
@class StatecStatementGroup;

@interface StatecMethod : NSObject

@property (assign) StatecScope scope;
@property (strong) NSString *returnType;
@property (assign) SEL selector;
@property (strong) StatecStatementGroup *body;
@property (strong) NSMutableArray *arguments;

- (id)initWithScope:(StatecScope)scope returnType:(NSString *)returnType selector:(SEL)selector;

- (void)addArgument:(StatecArgument *)argument;

- (BOOL)isInstanceScope;
- (BOOL)isClassScope;

- (NSString *)declarationString;
- (NSString *)definitionString;


@end
