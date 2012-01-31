//
//  Statec.h
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Statec_Statec_h
#define Statec_Statec_h

typedef enum {
  StatecInstanceScope,
  StaticClassScope,
  StatecGlobalScope
} StatecScope;

#import "StatecClass.h"
#import "StatecMethod.h"
#import "StatecArgument.h"
#import "StatecProperty.h"
#import "StatecVariable.h"

#import "StatecParser.h"
#import "StatecMachine.h"
#import "StatecInitial.h"
#import "StatecState.h"
#import "StatecEnter.h"
#import "StatecExit.h"
#import "StatecEvent.h"

#import "StatecCompiler.h"

#endif
