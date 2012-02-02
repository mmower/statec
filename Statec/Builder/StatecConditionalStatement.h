//
//  StatecConditionalStatement.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StatecStatement.h"

@interface StatecConditionalStatement : StatecStatement

@property (strong) NSString *condition;
@property (strong) StatecStatement *ifTrue;
@property (strong) StatecStatement *ifFalse;

- (id)initWithCondition:(NSString *)condition;

@end
