//
//  SFPropertyModel.h
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatecProperty : NSObject

@property (strong) NSMutableArray *attributes;

@property (strong) NSString *type;
@property (strong) NSString *name;

- (NSString *)declarationString;
- (NSString *)definitionString;

@end
