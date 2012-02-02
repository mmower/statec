//
//  StatecState.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreParse/CoreParse.h>

@class StatecMachine;


@interface StatecState : NSObject <CPParseResult>

@property (strong) NSString *name;
@property (assign) BOOL wantsEnter;
@property (assign) BOOL wantsExit;
@property (strong,readonly) NSArray *events;

- (BOOL)respondsToEventName:(NSString *)eventName;

- (NSString *)enterStateMethodName;
- (NSString *)exitStateMethodName;

- (NSString *)stateVariableName;

- (NSString *)stateClassNameInMachine:(StatecMachine *)machine;

@end
