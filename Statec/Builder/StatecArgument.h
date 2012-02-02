//
//  StatecArgument.h
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatecArgument : NSObject

@property (strong) NSString *type;
@property (strong) NSString *name;

- (id)initWithType:(NSString *)type name:(NSString *)name;

- (NSString *)argumentString;

@end
