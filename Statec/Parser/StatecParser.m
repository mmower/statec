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

@synthesize delegate = _delegate;


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
                        @"2 StatecState       ::= \"@state\" \"String\" \"{\" <StatecEnter>? <StatecExit>? <StatecEvent>* \"}\" ;"
                        @"3 StatecEnter       ::= \"@enter\" ;"
                        @"4 StatecExit        ::= \"@exit\" ;"
                        @"5 StatecEvent       ::= \"@event\" \"String\" \"=>\" \"String\" ;"];

  return grammar;
}


- (CPParser *)parser {
  return [CPLALR1Parser parserWithGrammar:[self grammar]];
}


- (NSUInteger)tokeniser:(CPTokeniser *)tokeniser didNotFindTokenOnInput:(NSString *)input position:(NSUInteger)position error:(NSString **)errorMessage {
  *errorMessage = [NSString stringWithFormat:@"unexpected character '%c' in input", [input characterAtIndex:0]];
  return NSNotFound;
}


- (CPTokenStream *)tokenStream:(NSString *)source {
  return [[self tokenizer] tokenise:source];
}


- (CPRecoveryAction *)parser:(CPParser *)parser didEncounterErrorOnInput:(CPTokenStream *)inputStream expecting:(NSSet *)acceptableTokens {
  CPToken *errorToken = [inputStream peekToken];
  
  if( [errorToken isKindOfClass:[CPErrorToken class]] ) {
    [[self delegate] parser:self syntaxError:[(CPErrorToken*)errorToken errorMessage] token:errorToken expected:acceptableTokens];
//    NSLog( @"Unexpected token at line:%ld col:%ld", [errorToken lineNumber], [errorToken columnNumber] );
//    NSLog( @"Error:%@", [(CPErrorToken*)errorToken errorMessage] );
  } else {
    [[self delegate] parser:self unexpectedToken:errorToken expected:acceptableTokens];
    NSLog( @"Unexpected %@ token at line:%ld col:%ld", [errorToken name], [errorToken lineNumber], [errorToken columnNumber] );
//    NSLog( @"Expecting one of: %@", [tokenNames componentsJoinedByString:@","] );
  }
  return [CPRecoveryAction recoveryActionStop];  
}



- (id<NSObject>)parse:(NSString *)source {
  NSLog( @"calling parse" );
  CPParser *parser = [self parser];
  [parser setDelegate:self];
  
  CPTokenStream *tokens = [self tokenStream:source];
  
  id<NSObject> result = [parser parse:tokens];
  return result;
}


@end
