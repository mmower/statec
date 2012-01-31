//
//  main.m
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreParse/CoreParse.h>

#import "Statec.h"

int main (int argc, const char * argv[])
{
  @autoreleasepool {
    NSError *error;
    
    
    NSString *source = [[NSString alloc] initWithContentsOfFile:@"/Volumes/Corrino/matt/foo.smd" encoding:NSUTF8StringEncoding error:&error];
    if( !source ) {
      NSLog( @"Cannot read source: %@", [error localizedDescription] );
      return -1;
    }
    
    StatecCompiler *compiler = [[StatecCompiler alloc] initWithSource:source];
    StatecCompilationUnit *unit = [compiler compiledMachine];
    if( ![unit writeFilesTo:@"/tmp/" error:&error] ) {
      NSLog( @"Cannot write class files: %@", [error localizedDescription] );
    }
  }
  
  return 0;
}

