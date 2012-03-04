//
//  StatecAppDelegate.h
//  StatecRunner
//
//  Created by Matt Mower on 02/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "StatecParser.h"

@interface StatecAppDelegate : NSObject <NSApplicationDelegate,StatecParserDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSPanel *statusPanel;

@property (strong) NSString *source;
@property (strong) NSString *sourceFile;
@property (strong) NSString *targetFolder;
@property (strong) NSString *statusMessage;

- (IBAction)pickSourceFile:(id)sender;
- (IBAction)pickTargetFolder:(id)sender;
- (IBAction)compile:(id)sender;
- (IBAction)dismissStatus:(id)sender;

@end
