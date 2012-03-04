//
//  MMStatecParser.h
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreParse/CoreParse.h>

@class StatecParser;

@protocol StatecParserDelegate <NSObject>

- (void)parser:(StatecParser *)parser syntaxError:(NSString *)message token:(CPToken *)token expected:(NSSet *)expected;
- (void)parser:(StatecParser *)parser unexpectedToken:(CPToken *)token expected:(NSSet *)expected;

@end


@interface StatecParser : NSObject <CPTokeniserDelegate,CPParserDelegate>

- (CPTokeniser *)tokenizer;
- (CPGrammar *)grammar;
- (CPParser *)parser;
- (CPTokenStream *)tokenStream:(NSString *)source;
- (id<NSObject>)parse:(NSString *)source;

@property id<StatecParserDelegate> delegate;

@end
