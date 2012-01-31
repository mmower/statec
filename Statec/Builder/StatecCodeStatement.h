//
//  StatecCodeStatement.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StatecStatement.h"

@interface StatecCodeStatement : StatecStatement

@property (strong) NSString *body;

- (id)initWithBody:(NSString *)body;

@end
