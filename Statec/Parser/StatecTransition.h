//
//  StatecTransition.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StatecEvent;
@class StatecState;

@interface StatecTransition : NSObject

@property (strong) StatecState *sourceState;
@property (strong) StatecState *targetState;
@property (strong) StatecEvent *event;

- (id)initWithSourceState:(StatecState *)sourceState targetState:(StatecState *)targetState viaEvent:(StatecEvent *)event;

@end
