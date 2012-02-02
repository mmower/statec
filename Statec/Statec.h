//
//  Statec.h
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#ifndef Statec_Statec_h
#define Statec_Statec_h

typedef enum {
  StatecInstanceScope = 1,
  StaticClassScope = 2,
  StatecGlobalScope = 4,
  StatecStaticScope = 8
} StatecScope;


#import "StatecCompilationUnit.h"
#import "StatecEnumeration.h"
#import "StatecType.h"
#import "StatecTypedef.h"
#import "StatecClass.h"
#import "StatecMethod.h"
#import "StatecArgument.h"
#import "StatecProperty.h"
#import "StatecVariable.h"
#import "StatecStatement.h"
#import "StatecCodeStatement.h"
#import "StatecConditionalStatement.h"
#import "StatecStatementGroup.h"

#import "StatecParser.h"
#import "StatecMachine.h"
#import "StatecInitial.h"
#import "StatecState.h"
#import "StatecEnter.h"
#import "StatecExit.h"
#import "StatecEvent.h"
#import "StatecTransition.h"

#import "StatecCompiler.h"


#endif
