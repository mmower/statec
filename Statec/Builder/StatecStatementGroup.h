//
//  StatecStatementGroup.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StatecStatement.h"

@interface StatecStatementGroup : StatecStatement

@property (strong) NSMutableArray *statements;

+ (StatecStatementGroup *)group;

- (id)initWithBody:(NSString *)body;
- (id)initWithStatement:(StatecStatement *)statement;


- (void)append:(NSString *)format, ...;
//- (void)addLine:(NSString *)line;
- (void)addStatement:(StatecStatement *)statement;


@end
