//
//  StatecHTMLBuilder.h
//  Statec
//
//  Created by Matt Mower on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StatecMachine;

@interface StatecHTMLBuilder : NSObject {
  StatecMachine *_machine;
}


- (id)initWithMachine:(StatecMachine *)machine;

- (BOOL)writeToFolder:(NSString *)folderPath error:(NSError **)error;

@end
