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
    
    NSString *outputFolder;
    NSString *inputFile;
    
    int bflag, ch;
    
    bflag = 0;
    while( ( ch = getopt( argc, argv, "d:i:" ) ) != -1 ) {
      switch( ch ) {
          case 'd':
          outputFolder = [[NSString alloc] initWithUTF8String:optarg];
          break;
          case 'i':
          inputFile = [[NSString alloc] initWithUTF8String:optarg];
          break;
      }
    }
    
    if( !outputFolder ) {
      outputFolder = @"./";
    }
    
    if( !inputFile ) {
      NSLog( @"No input file specified." );
      return -1;
    }
    
    inputFile = [inputFile stringByExpandingTildeInPath];
    outputFolder = [outputFolder stringByExpandingTildeInPath];
    
    NSString *source = [[NSString alloc] initWithContentsOfFile:inputFile encoding:NSUTF8StringEncoding error:&error];
    if( !source ) {
      NSLog( @"Cannot read source: \"%@\" %@", inputFile, [error localizedDescription] );
      return -1;
    }
    
    StatecCompiler *compiler = [[StatecCompiler alloc] initWithSource:source];
    StatecCompilationUnit *unit = [compiler generatedMachine];
    if( ![unit writeFilesTo:outputFolder error:&error] ) {
      NSLog( @"Cannot write class files: %@", [error localizedDescription] );
      return -1;
    }
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if( ![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@.h",[[[compiler machine] name] capitalizedString]]] ) {
      unit = [compiler userMachine];
      if( ![unit writeFilesTo:outputFolder error:&error] ) {
        NSLog( @"Cannot write class files %@", [error localizedDescription] );
        return -1;
      }
    }
  }
  
  return 0;
}

