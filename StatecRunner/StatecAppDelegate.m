//
//  StatecAppDelegate.m
//  StatecRunner
//
//  Created by Matt Mower on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecAppDelegate.h"

#import "StatecParser.h"
#import "StatecCompiler.h"
#import "StatecCompilationUnit.h"

@implementation StatecAppDelegate

@synthesize window = _window;

@synthesize statusPanel = _statusPanel;

@synthesize source = _source;
@synthesize sourceFile = _sourceFile;
@synthesize targetFolder = _targetFolder;
@synthesize statusMessage = _statusMessage;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [self setSourceFile:@""];
  [self setTargetFolder:@""];
  [self setStatusMessage:@""];
}


- (IBAction)pickSourceFile:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseFiles:YES];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
    if( NSFileHandlingPanelOKButton == result ) {
      NSURL *fileURL = [[openPanel URLs] objectAtIndex:0];
      [self setSourceFile:[fileURL path]];
      if( [[self targetFolder] isEqualToString:@""] ) {
        [self setTargetFolder:[[fileURL path] stringByDeletingLastPathComponent]];
      }
    }
  }];
}
 


- (IBAction)pickTargetFolder:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseFiles:NO];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
    if( NSFileHandlingPanelOKButton == result ) {
      NSURL *fileURL = [[openPanel URLs] objectAtIndex:0];
      [self setTargetFolder:[fileURL path]];
    }
  }];
}


- (IBAction)compile:(id)sender {
  NSError *error;
  BOOL overwriteUserFiles = NO;
  
  if( [[self sourceFile] isEqualToString:@""] ) {
    NSBeep();
    return;
  }
  
  if( [[self targetFolder] isEqualToString:@""] ) {
    NSBeep();
    return;
  }
  
  [NSApp beginSheet:[self statusPanel] modalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL isDirectory;
  if( ![fileManager fileExistsAtPath:[self targetFolder] isDirectory:&isDirectory] || !isDirectory ) {
    [self setStatusMessage:[NSString stringWithFormat:@"Output folder \"%@\" does not exist, or is not a directory", [self targetFolder]]];
    NSBeep();
    return;
  }
  
  [self setSource:[[NSString alloc] initWithContentsOfFile:[self sourceFile] encoding:NSUTF8StringEncoding error:&error]];
  if( ![self source] ) {
    [self setStatusMessage:[NSString stringWithFormat:@"Cannot read source: \"%@\" %@", [self sourceFile], [error localizedDescription]]];
    NSBeep();
    return;
  }
  
  StatecCompiler *compiler = [[StatecCompiler alloc] init];
  if( !compiler ) {
    [self setStatusMessage:@"Cannot initialize compiler"];
    NSBeep();
    return;
  }
  
  [[compiler parser] setDelegate:self];
  
  if( ![compiler parse:[self source]] ) {
    NSBeep();
    return;
  }
  
  
  NSArray *issues;
  if( ![compiler isMachineValid:&issues] ) {
    NSMutableString *errorString = [NSMutableString stringWithFormat:@"Machine definition is invalid (%ld issues):\n", [issues count]];
    for( NSString *issue in issues ) {
      [errorString appendFormat:@"* %@\n", issue];
    }
    [self setStatusMessage:errorString];
    NSBeep();
    return;
  } else {
    [self setStatusMessage:@"Compiled machine classes"];
  }
  
  StatecCompilationUnit *unit = [compiler generatedMachine];
  if( ![unit writeFilesTo:[self targetFolder] error:&error] ) {
    [self setStatusMessage:[NSString stringWithFormat:@"Cannot write class files: %@", [error localizedDescription]]];
    NSBeep();
    return;
  } else {
    [self setStatusMessage:@"Written machine implementation files"];
  }
  
  unit = [compiler userMachine];
  if( overwriteUserFiles || ![fileManager fileExistsAtPath:[[self targetFolder] stringByAppendingPathComponent:[unit headerFileName]]] ) {
    if( ![unit writeFilesTo:[self targetFolder] error:&error] ) {
      [self setStatusMessage:[NSString stringWithFormat:@"Cannot write class files %@", [error localizedDescription]]];
      NSBeep();
      return;
    }
  }
}


- (IBAction)dismissStatus:(id)sender {
  [NSApp endSheet:[self statusPanel]];
  [[self statusPanel] orderOut:sender];
}


- (NSString *)sourceLineForToken:(CPToken *)token {
  NSUInteger startPosition;
  NSUInteger endPosition;
  [[self source] getLineStart:&startPosition end:&endPosition contentsEnd:NULL forRange:NSMakeRange( [token characterNumber], 1 )];
  return [[self source] substringWithRange:NSMakeRange( startPosition, endPosition-startPosition-1 )];
}


- (NSString *)indicatorLine:(NSUInteger)characterPosition {
  
  NSMutableString *line = [NSMutableString string];
  while( characterPosition-- ) {
    [line appendString:@"-"];
  };
  [line appendString:@"^"];
  return line;
}


- (void)parser:(StatecParser *)parser syntaxError:(NSString *)message token:(CPToken *)token expected:(NSSet *)expected {
  [self setStatusMessage:[NSString stringWithFormat:
                          @"Syntax error on line %ld:%ld\n%@\n%@\n%@\nExpected: %@",
                          [token lineNumber],
                          [token columnNumber],
                          [self sourceLineForToken:token],
                          [self indicatorLine:[token columnNumber]],
                          message,
                          [[expected allObjects] componentsJoinedByString:@","]
                          ]];
}


- (void)parser:(StatecParser *)parser unexpectedToken:(CPToken *)token expected:(NSSet *)expected {
  [self setStatusMessage:[NSString stringWithFormat:
                          @"Unexpected input '%@' on line:%ld:%ld\n%@\n%@\nExpected: %@",
                          [token name],
                          [token lineNumber],
                          [token columnNumber],
                          [self sourceLineForToken:token],
                          [self indicatorLine:[token columnNumber]],
                          [[expected allObjects] componentsJoinedByString:@","]
                          ]];
}


@end
