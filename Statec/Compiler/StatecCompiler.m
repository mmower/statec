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


- (id)initWithSource:(NSString *)source {
  self = [super init];
  if( self ) {
    StatecParser *parser = [[StatecParser alloc] init];
    _machine = (StatecMachine *)[parser parse:source];
    if( !_machine ) {
      return nil;
    }
  }
  return self;
}


- (StatecMethod *)classInitializer {
  return nil;
}


- (StatecMethod *)initializer:(StatecVariable *)stateVariable {
  StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"id" selector:@selector(init)];
  
  StatecStatementGroup *group = [[StatecStatementGroup alloc] init];
  [group addLine:@"self = [super init];"];
  [group addLine:@"if( self ) {"];
  [group addLine:[NSString stringWithFormat:@"%@ = %@;", [stateVariable name], [NSString stringWithFormat:@"_%@State",[[_machine initialState] lowercaseString]]]];
  [group addLine:@"}"];
  [group addLine:@"return self;"];
  
  [method setBody:group];
  
  return method;
}


- (StatecMethod *)transitionMethod:(StatecType *)stateType {
  StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"BOOL" selector:@selector(canTransitionFromSourceState:toTargetState:)];
  [method addArgument:[[StatecArgument alloc] initWithType:[stateType name] name:@"sourceState"]];
  [method addArgument:[[StatecArgument alloc] initWithType:[stateType name] name:@"targetState"]];
  return method;                      
}


- (StatecMethod *)eventMethodForEvent:(NSString *)event state:(StatecVariable *)state withTransitions:(NSArray *)transitions {
  SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@Event",[event lowercaseString]]);
  
  StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope 
                                                  returnType:@"void" 
                                                    selector:selector];
  
  
  NSString *condition = [NSString stringWithFormat:@"[%@ respondsToSelector:@selector(%@)]", [state name], NSStringFromSelector(selector)];
  StatecConditionalStatement *condStatement = [[StatecConditionalStatement alloc] initWithCondition:condition];
  [condStatement setIfTrue:[[StatecStatementGroup alloc] initWithBody:@"NSLog( @\"Event\" )"]];
  [condStatement setIfFalse:[[StatecStatementGroup alloc] initWithBody:[NSString stringWithFormat:@"[NSException raise:@\"StateMachineException\" format:@\"Illegal event %@\"]", event]]];
  
  [method setBody:[[StatecStatementGroup alloc] initWithStatement:condStatement]];
  
   return method;
}


- (NSArray *)eventMethods:(StatecVariable *)stateVariable {
  NSMutableArray *methods = [NSMutableArray array];
  for( NSString *eventName in [_machine events] ) {
    [methods addObject:[self eventMethodForEvent:eventName 
                                           state:stateVariable
                                 withTransitions:[[_machine events] objectForKey:eventName]]];
  }
  return methods;
}


- (StatecCompilationUnit *)compiledMachine {
  StatecCompilationUnit *unit = [[StatecCompilationUnit alloc] initWithName:[_machine name]];
  
  StatecClass *machineClass = [[StatecClass alloc] initWithName:[_machine name]];

  
  StatecClass *stateBaseClass = [[StatecClass alloc] initWithName:[NSString stringWithFormat:@"%@State",[_machine name]]];
  [unit addClass:stateBaseClass];
  
  NSString *stateBaseClassPtrName = [NSString stringWithFormat:@"%@*",[stateBaseClass name]];

  
  for( NSString *stateName in [_machine states] ) {
    StatecClass *stateClass = [[StatecClass alloc] initWithname:[NSString stringWithFormat:@"%@%@State",[_machine name],[stateName capitalizedString]] baseClass:stateBaseClass];
    
    StatecState *state = [[_machine states] objectForKey:stateName];
    for( StatecEvent *event in [state events] ) {
      StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selector:NSSelectorFromString([NSString stringWithFormat:@"%@Event",[[event name] lowercaseString]])];
      [stateClass addMethod:method];
    }
    
    [unit addClass:stateClass];
    
    StatecVariable *stateGlobalVariable = [[StatecVariable alloc] initWithScope:StatecGlobalScope|StatecStaticScope
                                                                           name:[NSString stringWithFormat:@"_%@State",[stateName lowercaseString]] 
                                                                           type:stateBaseClassPtrName];
    [unit addVariable:stateGlobalVariable];
  }
  
  
  
  StatecVariable *stateVariable = [[StatecVariable alloc] initWithScope:StatecInstanceScope 
                                                                   name:@"_currentState"
                                                                   type:stateBaseClassPtrName];
  
  
  
  
  
  [machineClass addVariable:stateVariable];
  
  [machineClass addInitializer:[self initializer:stateVariable]];
  
//  [class addMethod:[self transitionMethod:stateType]];
  [machineClass addMethods:[self eventMethods:stateVariable]];
  
  [unit addClass:machineClass];
  
  return unit;
}


@end
