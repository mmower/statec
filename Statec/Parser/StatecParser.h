//
//  MMStatecParser.h
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreParse/CoreParse.h>

@interface StatecParser : NSObject <CPTokeniserDelegate>

- (CPTokeniser *)tokenizer;
- (CPGrammar *)grammar;
- (CPParser *)parser;
- (CPTokenStream *)tokenStream:(NSString *)source;
- (id<NSObject>)parse:(NSString *)source;

@end
