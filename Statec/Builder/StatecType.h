//
//  StatecType.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatecType : NSObject

@property (strong) NSString *name;

- (id)initWithName:(NSString *)name;


- (NSString *)statementString;

@end
