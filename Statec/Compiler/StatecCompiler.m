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


/*
 Generate an initializer for the machine class that initializes a global instance of each of the state
 subclasses. Because they are stateless they can be shared by all instances of the machine.
 */
- (StatecMethod *)classInitializer {
  StatecMethod *method = [[StatecMethod alloc] initWithScope:StaticClassScope returnType:@"void" selector:@selector(initialize)];
  
  StatecStatementGroup *body = [StatecStatementGroup group];
  [body append:
   @"static dispatch_once_t onceToken;\n"
   @"dispatch_once(&onceToken, ^{\n"];
  
  for( NSString *stateName in [_machine states] ) {
    [body append:@"_%@State = [[%@%@State alloc] init];\n", [stateName lowercaseString], [_machine name], [stateName capitalizedString]];
  }
  
  [body append:
   @"});"];
  
  [method setBody:body];
  
  return method;
}



/*
 Generate the initializer for the machine class. This should initialize the current state variable to point
 to the global instance of the state subclass for the initial state.
 */
- (StatecMethod *)initializer:(StatecVariable *)stateVariable {
  StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"id" selector:@selector(init)];
  
  StatecStatementGroup *group = [[StatecStatementGroup alloc] init];
  [group append:
   @"self = [super init];\n"
   @"if( self ) {\n"
   @"%@\n"
   @"}\n"
   @"return self;\n",[NSString stringWithFormat:@"%@ = %@;", [stateVariable name], [NSString stringWithFormat:@"_%@State",[[_machine initialState] lowercaseString]]]];
  
  [method setBody:group];
  
  return method;
}


/*
 Generate a method, to be added to the machine class, to respond to a specific event.
 
 The method tests whether the current state class can respond to this event. If it can then the event is passed
 on to the current state class. Otherwise an exception is raised to report the illegal attempted transition.
 */
- (StatecMethod *)eventMethodForEvent:(NSString *)event state:(StatecVariable *)state withTransitions:(NSArray *)transitions {
  SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@Event",[event lowercaseString]]);
  
  StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope 
                                                  returnType:@"void" 
                                                    selector:selector];
  
  NSString *stateMethodName = [NSString stringWithFormat:@"%@EventFromMachine:",[event lowercaseString]];
  [method setBody:[[StatecStatementGroup alloc] initWithFormat:@"[%@ %@self];",[state name], stateMethodName]];
  return method;
}


/*
 Generate event methods which will be added to the machine class.
 
 A method for every event (across all states) is added here.
 */
- (NSArray *)eventMethods:(StatecVariable *)stateVariable {
  NSMutableArray *methods = [NSMutableArray array];
  for( NSString *eventName in [_machine events] ) {
    [methods addObject:[self eventMethodForEvent:eventName 
                                           state:stateVariable
                                 withTransitions:[[_machine events] objectForKey:eventName]]];
  }
  return methods;
}


/*
 Generate a subclass of <Foo>State to represent a concrete state in <Foo>Machine.
 */
- (StatecClass *)stateClass:(StatecState *)state baseClass:(StatecClass *)baseClass machineClass:(StatecClass *)machineClass {
  StatecClass *stateClass = [[StatecClass alloc] initWithname:[NSString stringWithFormat:@"%@%@State",[_machine name],[[state name] capitalizedString]] baseClass:baseClass];
  
  // For every event this state recognises define an event method
  // that traverses to the target state
  for( StatecEvent *event in [state events] ) {
    StatecMethod *eventMethod = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selectorFormat:@"%@EventFromMachine:",[[event name] lowercaseString]];
    [eventMethod addArgument:[[StatecArgument alloc] initWithType:[machineClass pointerType] name:@"machine"]];
    
    StatecStatementGroup *body = [StatecStatementGroup group];
    
    [body append:@" NSLog( @\"Respond to event: %@\" ); \n ", [event name]];
    if( [state wantsExit] ) {
      [body append:@"[machine exit%@State];\n", [[state name] capitalizedString]];
    }
    [body append:@"[machine transitionToState:_%@State];\n", [[event targetState] lowercaseString]];
    
    [eventMethod setBody:body];
    [stateClass addMethod:eventMethod];
  }
  
  if( [state wantsEnter] ) {
    StatecMethod *enterMethod = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selector:@selector(enterFromMachine:)];
    [enterMethod addArgument:[[StatecArgument alloc] initWithType:[machineClass pointerType] name:@"machine"]];
    StatecStatementGroup *body = [StatecStatementGroup group];
    [body append:
     @"[machine enter%@State];\n", [[state name] capitalizedString]
     ];
    [enterMethod setBody:body];
    [stateClass addMethod:enterMethod];
  }
  
  return stateClass;
}

/*
 Generate the <Foo>Machine class.
 */
- (StatecClass *)machineClassWithStateBaseClass:(StatecClass *)stateBaseClass {
  // Create the class <Foo>Machine that will represent the machine itself
  StatecClass *machineClass = [[StatecClass alloc] initWithName:[NSString stringWithFormat:@"%@Machine",[_machine name]]];
  
  // Add the +initialize method to create the state subclasses
  [machineClass addMethod:[self classInitializer]];

  // Add to the machine class an instance variable representing the current state
  StatecVariable *stateVariable = [[StatecVariable alloc] initWithScope:StatecInstanceScope 
                                                                   name:@"_currentState"
                                                                   type:[stateBaseClass pointerType]];
  [machineClass addVariable:stateVariable];

  // Add to the machine class it's -init method that sets the initial state
  [machineClass addInitializer:[self initializer:stateVariable]];
  
  // Add an event method, for all events, to the machine class
  [machineClass addMethods:[self eventMethods:stateVariable]];
  
  // For every state that wanted enter notification we provide a callback that can be overridden
  // by the user state machine class
  for( NSString *stateName in [_machine states] ) {
    StatecState *state = [[_machine states] objectForKey:stateName];
    if( [state wantsEnter] ) {
      StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selectorFormat:@"enter%@State",[[state name] capitalizedString]];
      [method setBody:[[StatecStatementGroup alloc] initWithFormat:@"// Override in user machine subclass"]];
      [machineClass addMethod:method];
    }
    if( [state wantsExit] ) {
      StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selectorFormat:@"exit%@State",[[state name] capitalizedString]];
      [method setBody:[[StatecStatementGroup alloc] initWithFormat:@"// Override in user machine subclass"]];
      [machineClass addMethod:method];
    }
  }
  
  StatecMethod *transitionMethod = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selector:@selector(transitionToState:)];
  [transitionMethod addArgument:[[StatecArgument alloc] initWithType:[stateBaseClass pointerType] name:@"state"]];
  StatecStatementGroup *body = [StatecStatementGroup group];
  [body append:
   @"[state enterFromMachine:self];\n"
   @"%@ = state;\n", [stateVariable name]
   ];
  [transitionMethod setBody:body];
  [machineClass addMethod:transitionMethod];
  
  return machineClass;
}


- (StatecCompilationUnit *)compiledMachine {
  StatecCompilationUnit *unit = [[StatecCompilationUnit alloc] initWithName:[_machine name]];
  
  // Create the base class <FooState> for the states
  StatecClass *stateBaseClass = [[StatecClass alloc] initWithName:[NSString stringWithFormat:@"%@State",[_machine name]]];
  [unit addClass:stateBaseClass];
  
  StatecClass *machineClass = [self machineClassWithStateBaseClass:stateBaseClass];
  
  // Now add to <Foo>State a method for each event that raises an exception if the event is
  // fired. Specific subclasses will override this with a method that handles the event if
  // the state recognises that event.
  for( NSString *eventName in [_machine events] ) {
    StatecMethod *eventMethod = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selectorFormat:@"%@EventFromMachine:",[eventName lowercaseString]];
    [eventMethod addArgument:[[StatecArgument alloc] initWithType:[machineClass pointerType] name:@"machine"]];
    [eventMethod setBody:[[StatecStatementGroup alloc] initWithFormat:@"[NSException raise:@\"StateMachineException\" format:@\"Illegal event '%@'!\"];",eventName]];
    [stateBaseClass addMethod:eventMethod];
  }
  
  // Add the generic enterFromMachine: method
  StatecMethod *enterMethod = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selector:@selector(enterFromMachine:)];
  [enterMethod addArgument:[[StatecArgument alloc] initWithType:[machineClass pointerType] name:@"machine"]];
  [enterMethod setBody:[[StatecStatementGroup alloc] initWithFormat:@"// Subclasses will redefine if enter callbacks are required for their state\n"]];
  [stateBaseClass addMethod:enterMethod];
  
  // Make the machine class available to the State classes that get declared before it
  [unit addForwardDeclaration:[machineClass name]];
  
  // For each state in the machine make a state subclass and create a global
  // pointer for a staticly allocated instance of the class
  for( NSString *stateName in [_machine states] ) {
    StatecState *state = [[_machine states] objectForKey:stateName];
    [unit addClass:[self stateClass:state baseClass:stateBaseClass machineClass:machineClass]];
    StatecVariable *stateGlobalVariable = [[StatecVariable alloc] initWithScope:StatecGlobalScope|StatecStaticScope
                                                                           name:[NSString stringWithFormat:@"_%@State",[stateName lowercaseString]] 
                                                                           type:[stateBaseClass pointerType]];
    [unit addVariable:stateGlobalVariable];
  }
  
  [unit addClass:machineClass];
  
  return unit;
}


@end
