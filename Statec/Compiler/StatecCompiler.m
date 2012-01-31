//
//  StatecCompiler.m
//  Statec
//
//  Created by Matt Mower on 31/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecCompiler.h"

#import "Statec.h"

@implementation StatecCompiler

- (StatecClass *)compileClassFromMachineDefinition:(NSString *)definition {
  StatecParser *parser = [[StatecParser alloc] init];
  StatecMachine *machine = (StatecMachine *)[parser parse:definition];
  StatecClass *class = [[StatecClass alloc] initWithName:[machine name]];
  
  [class addVariable:[[StatecVariable alloc] initWithScope:StatecInstanceScope 
                                                      name:@"_state"
                                                      type:@"NSUInteger"]];
  
  
  for( NSString *event in [machine events] ) {
    StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selector:NSSelectorFromString(event)];
    [class addMethod:method];
  }
  
  return class;
}


@end
