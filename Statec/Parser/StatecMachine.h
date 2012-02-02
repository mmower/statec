//
//  Machine.h
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreParse/CoreParse.h>

@interface StatecMachine : NSObject <CPParseResult>

@property (strong) NSString *name;
@property (strong) NSString *initialState;
@property (strong) NSDictionary *states;
@property (strong) NSDictionary *events;

- (BOOL)validateMachine:(NSArray **)issues;

@end
