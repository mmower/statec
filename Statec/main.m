//
//  main.m
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Statec.h"

int main (int argc, const char * argv[])
{
  @autoreleasepool {
    NSError *error;
    
    StatecClass *class = [[StatecClass alloc] initWithName:@"Test"];
    
    StatecVariable *var = [[StatecVariable alloc] initWithScope:StatecInstanceScope name:@"_foo" type:@"int"];
    
    [[class variables] addObject:var];
                           
    
    StatecProperty *property = [[StatecProperty alloc] init];
    [property setName:@"name"];
    [property setType:@"NSString *"];
    [[property attributes] addObject:@"strong"];
    [[class properties] addObject:property];
    
    
    StatecMethod *method = [[StatecMethod alloc] initWithScope:StatecInstanceScope returnType:@"void" selector:@selector(foo:)];
    [[method arguments] addObject:[[StatecArgument alloc] initWithType:@"NSString*" name:@"foo"]];
    [[class methods] addObject:method];
    
    if( ![class writeClassFilesTo:@"/tmp/" error:&error] ) {
      NSLog( @"Cannot write class files: %@", [error localizedDescription] );
    }
  }
  
  return 0;
}

