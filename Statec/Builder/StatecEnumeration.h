//
//  StatecEnumeration.h
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StatecType.h"

@interface StatecEnumeration : StatecType {
  NSMutableArray *_elements;
}

- (void)addElement:(NSString *)element;

@end
