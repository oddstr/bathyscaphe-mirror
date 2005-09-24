//
//  SmartBoardListItem.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AbstractDBBoardListItem.h"

@class SmartConditionItem;

@interface SmartBoardListItem : AbstractDBBoardListItem
{
	NSMutableArray *conditions;
	NSString *name;
}

-(id)initWithName:(NSString *)name condition:(id)condition;

@end
