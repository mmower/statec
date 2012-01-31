//
//  StatecState.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreParse/CoreParse.h>


@interface StatecState : NSObject <CPParseResult>

@property (strong) NSString *name;
@property (assign) BOOL wantsEnter;
@property (assign) BOOL wantsExit;
@property (strong,readonly) NSArray *events;

@end
