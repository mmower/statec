//
//  StatecCompiler.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StatecCompilationUnit;

@interface StatecCompiler : NSObject

- (StatecCompilationUnit *)compileMachine:(NSString *)definition;

@end
