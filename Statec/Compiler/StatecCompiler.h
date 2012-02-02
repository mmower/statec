//
//  StatecCompiler.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StatecMachine;
@class StatecCompilationUnit;

@interface StatecCompiler : NSObject {
}

@property (strong) StatecMachine *machine;
@property (strong) StatecCompilationUnit *generatedUnit;

- (id)initWithSource:(NSString *)source;

- (BOOL)isMachineValid:(NSArray **)issues;

- (StatecCompilationUnit *)generatedMachine;
- (StatecCompilationUnit *)userMachine;

@end
