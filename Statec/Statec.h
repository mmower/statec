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

#endif
