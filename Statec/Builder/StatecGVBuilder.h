//
//  StatecGVBuilder.h
//  Statec
//
//  Created by Matt Mower on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StatecMachine;

@interface StatecGVBuilder : NSObject

- (NSString *)gvSourceFromMachine:(StatecMachine *)machine;

@end
