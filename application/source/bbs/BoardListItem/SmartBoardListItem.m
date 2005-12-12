//
//  SmartBoardListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SmartBoardListItem.h"

#import "DatabaseManager.h"

@implementation SmartBoardListItem

- (NSImage *) icon
{
	return [NSImage imageAppNamed : @"SmartBoard"];
}


- (id) initWithName : (NSString *) inName condition : (id) condition
{
	if (self = [super init]) {
		[self setName : inName];
	}
	
	return self;
}

@end
