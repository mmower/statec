//
//  MMStatecParser.m
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 SmartFish Software Ltd.. All rights reserved.
//

#import "StatecParser.h"

#import <CoreParse/CoreParse.h>

@implementation StatecParser


- (CPTokeniser *)tokenizer {
  CPTokeniser *tokenizer = [[CPTokeniser alloc] init];
  
  [tokenizer addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"{"]];
  [tokenizer addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"}"]];
  [tokenizer addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"=>"]];
  [tokenizer addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"@machine"]];
  [tokenizer addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"@initial"]];
  [tokenizer addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"@state"]];
  [tokenizer addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"@event"]];
  [tokenizer addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"@enter"]];
  [tokenizer addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"@exit"]];
  [tokenizer addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"\"" endQuote:@"\"" name:@"String"]];
  [tokenizer addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
  [tokenizer addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"//" endQuote:@"\n" name:@"Comment"]];
  [tokenizer addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
  
  [tokenizer setDelegate:self];
  
  return tokenizer;
}


- (BOOL)tokeniser:(CPTokeniser *)tokeniser shouldConsumeToken:(CPToken *)token {
  return YES;
}


- (NSArray *)tokeniser:(CPTokeniser *)tokeniser willProduceToken:(CPToken *)token {
  if( [token isKindOfClass:[CPWhiteSpaceToken class]] || [[token name] isEqualToString:@"Comment"] ) {
    return [NSArray array];
  } else {
    return [NSArray arrayWithObject:token];
  }
}


- (CPGrammar *)grammar {
  CPGrammar *grammar = [[CPGrammar alloc] initWithStart:@"StatecMachine" 
                                         backusNaurForm:
                        @"0 StatecMachine     ::= \"@machine\" \"String\" \"{\" <StatecInitial> <StatecState>+ \"}\" ;" 
                        @"1 StatecInitial     ::= \"@initial\" \"String\" ;"
                        @"2 StatecState       ::= \"@state\" \"String\" \"{\" <StatecEnter>? <StatecExit>? <StatecEvent>+ \"}\" ;"
                        @"3 StatecEnter       ::= \"@enter\" ;"
                        @"4 StatecExit        ::= \"@exit\" ;"
                        @"5 StatecEvent       ::= \"@event\" \"String\" \"=>\" \"String\" ;"];

  return grammar;
}


- (CPParser *)parser {
  return [CPSLRParser parserWithGrammar:[self grammar]];
}


- (CPTokenStream *)tokenStream:(NSString *)source {
  return [[self tokenizer] tokenise:source];
}


- (id<NSObject>)parse:(NSString *)source {
  
  CPParser *parser = [self parser];
  CPTokenStream *tokens = [self tokenStream:source];
  
  return [parser parse:tokens];
}


@end
