//
//  BSBoardListItemHEADCheckTask.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/08/13.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMRThreadLayoutTask.h"
#import "BoardListItem.h"

@interface BSBoardListItemHEADCheckTask : CMRThreadLayoutConcreateTask
{
	BoardListItem *item;
	
	NSString *amountString;
	NSString *descString;
}


+ (id)taskWithBoardListItem:(BoardListItem *)item;
- (id)initWithBoardListItem:(BoardListItem *)item;


@end
