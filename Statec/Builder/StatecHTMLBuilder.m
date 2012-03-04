//
//  StatecHTMLBuilder.m
//  Statec
//
//  Created by Matt Mower on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecHTMLBuilder.h"

#import "Statec.h"

@implementation StatecHTMLBuilder

- (id)initWithMachine:(StatecMachine *)machine {
  self = [super init];
  if( self ) {
    _machine = machine;
  }
  return self;
}


- (NSString *)htmlForMachine {
  NSMutableString *content = [NSMutableString string];
  
  [content appendFormat:
   @"<html>\n<head>\n<title>%@</title>\n</head>\n<body>\n<h1>States</h1>\n<table>\n",
   [_machine name]
   ];
  
  for( StatecState *state in [[_machine states] allValues] ) {
    [content appendFormat:
     @"<tr><td colspan='2'>State: %@</td></tr>\n",
     [state name]
     ];
    
    NSString *enterMethodName = @"", *exitMethodName = @"";
    if( [state wantsEnter] ) {
      enterMethodName = [state enterStateMethodName];
    }
    if( [state wantsExit] ) {
      exitMethodName = [state exitStateMethodName];
    }
    
    [content appendFormat:
     @"<tr><td>%@</td><td>%@</td></tr>",
     enterMethodName,
     exitMethodName
     ];
    
    for( StatecEvent *event in [state events] ) {
      [content appendFormat:
       @"<tr><td>%@</td><td>-&gt;&nbsp;%@</td></tr>",
       [event callbackMethodName],
       [event targetState]
       ];
    }
  }
  
  [content appendString:
   @"</table>\n</body>\n</html>\n"
   ];
  
  
  return content;
}


- (BOOL)writeToFolder:(NSString *)folderPath error:(NSError **)error {
  return [[self htmlForMachine] writeToFile:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html",[_machine name]]] 
                                 atomically:NO
                                   encoding:NSUTF8StringEncoding error:error];
}



@end
