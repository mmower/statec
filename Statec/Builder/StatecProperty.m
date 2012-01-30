//
//  SFPropertyModel.m
//  Statec
//
//  Created by Matt Mower on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatecProperty.h"

@implementation StatecProperty

@synthesize attributes = _attributes;
@synthesize type = _type;
@synthesize name = _name;


- (id)init {
  self = [super init];
  if( self ) {
    _attributes = [NSMutableArray array];
  }
  return self;
}

- (id)initWithType:(NSString *)type name:(NSString *)name {
  self = [self init];
  if( self ) {
    _type = type;
    _name = name;
  }
  return self;
}


- (NSString *)attributesString {
  return [[self attributes] componentsJoinedByString:@","];
}


- (NSString *)declarationString {
  return [NSString stringWithFormat:@"@property (%@) %@ %@;\n", [self attributesString], [self type], [self name]];
}


- (NSString *)definitionString {
  return [NSString stringWithFormat:@"@synthesize %@ = _%@;\n", [self name], [self name]];
}


@end
