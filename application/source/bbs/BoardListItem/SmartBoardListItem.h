//
//  SmartBoardListItem.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AbstractDBBoardListItem.h"
#import "SmartCondition.h"

@interface SmartBoardListItem : AbstractDBBoardListItem
{
	id<SmartCondition> mConditions;
}

- (id) initWithName : (NSString *) name condition : (id) condition;

- (id) condition;
- (void) setCondition:(id)condition;

@end
