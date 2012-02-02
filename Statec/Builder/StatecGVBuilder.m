//
//  StatecGVBuilder.m
//  Statec
//
//  Created by Matt Mower on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecGVBuilder.h"

#import "Statec.h"

@implementation StatecGVBuilder

- (NSString *)gvTransitions:(StatecMachine *)machine {
  NSMutableString *gv = [NSMutableString string];
  
  for( StatecState *state in [[machine states] allValues] ) {
    for( StatecEvent *event in [state events] ) {
      [gv appendFormat:
       @"%@ -> %@ [label = \"%@\"];\n",
       [state name],
       [event targetState],
       [event name]
       ];
    }
  }
  
  return gv;
}


- (NSString *)gvSourceFromMachine:(StatecMachine *)machine {
  NSMutableString *gv = [NSMutableString string];
  
  [gv appendFormat:
   @"digraph %@ {\n"
   @"  rankdir=LR;\n"
//   @"  size=\"16,8\";\n"
   @"  node [shape = circle];\n"
   @"  node [fontsize = 15];\n"
   @"  node [fontfamily = inconsolata];\n"
   @"  edge [fontsize = 15];\n"
   @"  edge [fontfamily = inconsolata];\n"
   @"%@"
   @"}",
   [machine name],
   [self gvTransitions:machine]
   ];
  
  return gv;
}



@end
