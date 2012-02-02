//
//  main.m
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreParse/CoreParse.h>

#import "Statec.h"

#import "StatecGVBuilder.h"

int main (int argc, const char * argv[])
{
  @autoreleasepool {
    NSError *error;
    
    NSString *outputFolder;
    NSString *inputFile;
    
    BOOL overwriteUserFiles = NO, generateGraph = NO;
    
    int ch;
    while( ( ch = getopt( argc, argv, "d:i:og" ) ) != -1 ) {
      switch( ch ) {
          case 'd':
          outputFolder = [[NSString alloc] initWithUTF8String:optarg];
          break;
          case 'i':
          inputFile = [[NSString alloc] initWithUTF8String:optarg];
          break;
          case 'o':
          overwriteUserFiles = YES;
          break;
          case 'g':
          generateGraph = YES;
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
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if( ![fileManager fileExistsAtPath:outputFolder isDirectory:&isDirectory] || !isDirectory ) {
      NSLog( @"Output folder \"%@\" does not exist, or is not a directory", outputFolder );
      return -1;
    }

    NSString *source = [[NSString alloc] initWithContentsOfFile:inputFile encoding:NSUTF8StringEncoding error:&error];
    if( !source ) {
      NSLog( @"Cannot read source: \"%@\" %@", inputFile, [error localizedDescription] );
      return -1;
    }
    
    StatecCompiler *compiler = [[StatecCompiler alloc] initWithSource:source];
    if( !compiler ) {
      NSLog( @"Syntax error in input" );
      return -1;
    }
    
    NSArray *issues;
    if( ![compiler isMachineValid:&issues] ) {
      NSLog( @"Machine definition is invalid (%ld issues):", [issues count] );
      for( NSString *issue in issues ) {
        NSLog( @"\t%@", issue );
      }
      return -1;
    }
    
    StatecCompilationUnit *unit = [compiler generatedMachine];
    if( ![unit writeFilesTo:outputFolder error:&error] ) {
      NSLog( @"Cannot write class files: %@", [error localizedDescription] );
      return -1;
    }
    
    unit = [compiler userMachine];
    if( overwriteUserFiles || ![fileManager fileExistsAtPath:[outputFolder stringByAppendingPathComponent:[unit headerFileName]]] ) {
      NSLog( @"No user file exists, writing user machine." );
      if( ![unit writeFilesTo:outputFolder error:&error] ) {
        NSLog( @"Cannot write class files %@", [error localizedDescription] );
        return -1;
      }
    } else {
      NSLog( @"User machine already exists." );
    }
    
    if( generateGraph ) {
      NSString *graphFileName = [outputFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gv",[[compiler machine] name]]];
      StatecGVBuilder *gvBuilder = [[StatecGVBuilder alloc] init];
      NSString *gvSource = [gvBuilder gvSourceFromMachine:[compiler machine]];
      [gvSource writeToFile:graphFileName
                 atomically:NO 
                   encoding:NSUTF8StringEncoding error:nil];
      
      
      NSString *pathEnv = [[[NSProcessInfo processInfo] environment] objectForKey:@"PATH"];
      NSArray *paths = [pathEnv componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
      for( NSString *path in paths ) {
        if( [fileManager fileExistsAtPath:[path stringByAppendingPathComponent:@"dot"]] ) {
          NSLog( @"Generating image file" );
          NSTask *dotTask = [NSTask launchedTaskWithLaunchPath:[path stringByAppendingPathComponent:@"dot"]
                                                     arguments:[NSArray arrayWithObjects:@"-O",@"-Tpng",graphFileName,nil]];
          [dotTask waitUntilExit];
        }
      }
    }
    
  }
  
  return 0;
}

