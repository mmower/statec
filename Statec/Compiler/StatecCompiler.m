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

- (StatecCompilationUnit *)compileMachine:(NSString *)definition {
  StatecParser *parser = [[StatecParser alloc] init];
  StatecMachine *machine = (StatecMachine *)[parser parse:definition];
  
  StatecCompilationUnit *unit = [[StatecCompilationUnit alloc] initWithName:[machine name]];
  
  StatecEnumeration *stateEnum = [[StatecEnumeration alloc] init];
  for( NSString *stateName in [machine states] ) {
    [stateEnum addElement:stateName];
  };
  
  StatecTypedef *stateType = [[StatecTypedef alloc] initWithName:[NSString stringWithFormat:@"%@State",[machine name]] type:stateEnum];
  
  [unit addType:stateType];
  
  StatecClass *class = [[StatecClass alloc] initWithName:[machine name]];
  
  [class addVariable:[[StatecVariable alloc] initWithScope:StatecInstanceScope 
                                                      name:@"_state"
                                                      type:[stateType name]]];
  
  
  for( NSString *event in [machine events] ) {
    StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selector:NSSelectorFromString(event)];
    [class addMethod:method];
  }
  
  [unit addClass:class];
  
  return unit;
}


@end
