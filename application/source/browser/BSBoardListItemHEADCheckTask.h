//
//  BSBoardListItemHEADCheckTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/13.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMRThreadLayoutTask.h"
#import "BSDBThreadList.h"
#import "BoardListItem.h"

@interface BSBoardListItemHEADCheckTask : CMRThreadLayoutConcreateTask
{
	BSDBThreadList *targetList;
	BoardListItem *item;
	
	NSString *amountString;
	NSString *descString;
}

+ (id)taskWithThreadList:(BSDBThreadList *)list;
- (id)initWithThreadList:(BSDBThreadList *)list;

//+ (id)taskWithBoardListItem:(BoardListItem *)item;
//- (id)initWithBoardListItem:(BoardListItem *)item;


@end
