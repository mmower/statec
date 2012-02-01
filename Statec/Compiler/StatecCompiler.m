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

@synthesize machine = _machine;
@synthesize generatedUnit = _generatedUnit;


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
  
  [[method body] append:
   @"static dispatch_once_t onceToken;\n"
   @"dispatch_once(&onceToken, ^{\n"];
  
  for( NSString *stateName in [_machine states] ) {
    [[method body] append:@"_%@State = [[%@%@State alloc] init];\n", [stateName lowercaseString], [_machine name], [stateName capitalizedString]];
  }
  
  [[method body] append:
   @"});"];
  
  return method;
}



/*
 Generate the initializer for the machine class. This should initialize the current state variable to point
 to the global instance of the state subclass for the initial state.
 */
- (StatecMethod *)initializer:(StatecVariable *)stateVariable queueVariable:(StatecVariable *)queueVariable {
  StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"id" selector:@selector(init)];
  [[method body] append:
   @"self = [super init];\n"
   @"if( self ) {\n"
   @"%@ = %@;\n"
   @"%@ = dispatch_queue_create( %@, DISPATCH_QUEUE_SERIAL );\n"
   @"}\n"
   @"return self;\n",
   [stateVariable name],
   [NSString stringWithFormat:@"_%@State",[[_machine initialState] lowercaseString]],
   [queueVariable name],
   [NSString stringWithFormat:@"[[NSString stringWithFormat:@\"%@Machine.%%p\",self] UTF8String]",[_machine name]]
   ];
  
  return method;
}


- (StatecMethod *)deallocQueueVariable:(StatecVariable *)queueVariable {
  StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selectorFormat:@"dealloc"];
  [[method body] append:
   @"dispatch_release( %@ );\n", [queueVariable name]
   ];
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
  [[method body] append:
   @"[%@ %@self];", [state name], stateMethodName
   ];
  
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
  
  StatecMethod *initializer = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"id" selector:@selector(init)];
  [[initializer body] append:
   @"return [self initWithName:@\"%@\"];\n",
   [state name]
   ];
  [stateClass addInitializer:initializer];
  
  // For every event this state recognises define an event method
  // that traverses to the target state
  for( StatecEvent *event in [state events] ) {
    StatecMethod *eventMethod = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selectorFormat:@"%@EventFromMachine:",[[event name] lowercaseString]];
    [eventMethod addArgument:[[StatecArgument alloc] initWithType:[machineClass pointerType] name:@"machine"]];
    [[eventMethod body] append:@" NSLog( @\"Respond to event: %@\" ); \n ", [event name]];
    if( [state wantsExit] ) {
      [[eventMethod body] append:@"[machine exit%@State];\n", [[state name] capitalizedString]];
    }
    [[eventMethod body] append:@"[machine transitionToState:_%@State];\n", [[event targetState] lowercaseString]];
    [stateClass addMethod:eventMethod];
  }
  
  if( [state wantsEnter] ) {
    StatecMethod *enterMethod = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selector:@selector(enterFromMachine:)];
    [enterMethod addArgument:[[StatecArgument alloc] initWithType:[machineClass pointerType] name:@"machine"]];
    [[enterMethod body] append:
     @"[machine enter%@State];\n", [[state name] capitalizedString]
     ];
    [stateClass addMethod:enterMethod];
  }
  
  return stateClass;
}

/*
 Generate the <Foo>Machine class.
 */
- (StatecClass *)machineClassWithStateBaseClass:(StatecClass *)stateBaseClass {
  // Create the class <Foo>Machine that will represent the machine itself
  StatecClass *machineClass = [[StatecClass alloc] initWithName:[NSString stringWithFormat:@"_%@Machine",[_machine name]]];
  
  // Add the +initialize method to create the state subclasses
  [machineClass addMethod:[self classInitializer]];
  
  // Add to the machine class an instance variable representing the current state
  StatecVariable *stateVariable = [[StatecVariable alloc] initWithScope:StatecInstanceScope 
                                                                   name:@"_currentState"
                                                                   type:[stateBaseClass pointerType]];
  [machineClass addVariable:stateVariable];
  
  StatecMethod *getStateMethod = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:[stateBaseClass pointerType] selector:@selector(currentState)];
  [[getStateMethod body] append:
   @"return %@;\n",
   [stateVariable name]
   ];
  [machineClass addMethod:getStateMethod];
  
  // Add to the machine class an instance variable represent a queue we will use to
  // serialize state changes
  StatecVariable *queueVariable = [[StatecVariable alloc] initWithScope:StatecInstanceScope
                                                                   name:@"_lock" 
                                                                   type:@"dispatch_queue_t"];
  [machineClass addVariable:queueVariable];

  // Add to the machine class it's -init method that sets the initial state
  [machineClass addInitializer:[self initializer:stateVariable queueVariable:queueVariable]];
  
  // Add the dealloc method to release the queue
  [machineClass addMethod:[self deallocQueueVariable:queueVariable]];
  
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
  [[transitionMethod body] append:
   @"dispatch_sync( %@, ^{\n"
   @"%@ = state;\n"
   @"[state enterFromMachine:self];\n"
   @"});\n",
   [queueVariable name],
   [stateVariable name]
   ];
  [machineClass addMethod:transitionMethod];
  
  return machineClass;
}


- (StatecClass *)stateBaseClass {
  // Create the base class <FooState> for the states
  StatecClass *class = [[StatecClass alloc] initWithName:[NSString stringWithFormat:@"%@State",[_machine name]]];
  
  // Oay this is a cheat, i shouldn't be passing two strings separated by a , for attributes
  [class addProperty:[[StatecProperty alloc] initWithType:@"NSString*" name:@"name" attribute:@"strong,readonly"]];
  
  StatecMethod *initializer = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"id" selector:@selector(initWithName:)];
  [initializer addArgument:[[StatecArgument alloc] initWithType:@"NSString*" name:@"name"]];
  [[initializer body] append:
   @"self = [super init];\n"
   @"if( self ) {\n"
   @"  _name = name;\n"
   @"}\n"
   @"return self;\n"
   ];
  [class addMethod:initializer];
  return class;
}


- (NSArray *)baseEventMethods:(StatecClass *)machineClass {
  NSMutableArray *methods = [NSMutableArray array];
  
  // Now add to <Foo>State a method for each event that raises an exception if the event is
  // fired. Specific subclasses will override this with a method that handles the event if
  // the state recognises that event.
  for( NSString *eventName in [_machine events] ) {
    StatecMethod *eventMethod = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selectorFormat:@"%@EventFromMachine:",[eventName lowercaseString]];
    [eventMethod addArgument:[[StatecArgument alloc] initWithType:[machineClass pointerType] name:@"machine"]];
    [[eventMethod body] append:
     @"[NSException raise:@\"StateMachineException\" format:@\"Event '%@' is not legal in state '%%@'!\",[self name]];",
     eventName
     ];
    [methods addObject:eventMethod];
  }

  return methods;
}


- (StatecCompilationUnit *)generatedMachine {
  StatecCompilationUnit *unit = [[StatecCompilationUnit alloc] initWithName:[NSString stringWithFormat:@"_%@Machine",[_machine name]]];
  
  [unit setComment:[NSString stringWithFormat:
   @"// This state machine file (_%@) was generated by Statec 0.1(0)\n"
   @"// Copyright (c) 2012 Matt Mower <self@mattmower.com>\n"
   @"// DO NOT EDIT THIS FILE - IT IS REGENERATED EVERY TIME STATEC IS RUN\n"
   @"// ONLY MAKE CHANGES IN THE USER FILE %@. YOU HAVE BEEN WARNED\n",
   [_machine name],
   [_machine name]
   ]];
  
  StatecClass *stateBaseClass = [self stateBaseClass];
  [unit addClass:stateBaseClass];
  
  StatecClass *machineClass = [self machineClassWithStateBaseClass:stateBaseClass];
  [stateBaseClass addMethods:[self baseEventMethods:machineClass]];
  
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
  [unit setPrincipalClass:machineClass];
  
  _generatedUnit = unit;
  
  return unit;
}


- (StatecCompilationUnit *)userMachine {
  StatecCompilationUnit *unit = [[StatecCompilationUnit alloc] initWithName:[NSString stringWithFormat:@"%@Machine",[_machine name]]];

  NSMutableString *commentString = [NSMutableString string];
  [commentString appendFormat:
   @"// State Machine %@ generated by Statec v0.1 on %@\n"
   @"// \n",
   [_machine name],
   [NSDate date]
   ];
  
  [unit setComment:commentString];
  
  [[unit declarationImports] addObject:[NSString stringWithFormat:@"_%@.h",[_machine name]]];
  
  StatecClass *userClass = [[StatecClass alloc] initWithname:[NSString stringWithFormat:@"%@Machine",[_machine name]] baseClass:[[self generatedUnit] principalClass]];
  
  // For every state that wanted enter notification we provide a callback stub the user can put their code in
  for( NSString *stateName in [_machine states] ) {
    StatecState *state = [[_machine states] objectForKey:stateName];
    if( [state wantsEnter] ) {
      StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selectorFormat:@"enter%@State",[[state name] capitalizedString]];
      [method setBody:[[StatecStatementGroup alloc] initWithFormat:@"// Your code here"]];
      [userClass addMethod:method];
    }
    if( [state wantsExit] ) {
      StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selectorFormat:@"exit%@State",[[state name] capitalizedString]];
      [method setBody:[[StatecStatementGroup alloc] initWithFormat:@"// Your code here"]];
      [userClass addMethod:method];
    }
  }
  
  [unit addClass:userClass];
  
  return unit;
}


@end
