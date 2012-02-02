//
//  StatecEvent.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreParse/CoreParse.h>


@interface StatecEvent : NSObject <CPParseResult>

@property (strong) NSString *name;
@property (strong) NSString *targetState;
@property (strong) NSMutableArray *transitions;

- (NSString *)callbackMethodName;
- (NSString *)internalCallbackMethodName;

@end
