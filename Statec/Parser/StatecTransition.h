//
//  StatecTransition.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StatecEvent;
@class StatecState;

@interface StatecTransition : NSObject

@property (strong) StatecState *sourceState;
@property (strong) StatecState *targetState;

- (id)initWithSourceState:(StatecState *)sourceState targetState:(StatecState *)targetState;

@end
