//
//  BoardBoardListItem.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AbstractDBBoardListItem.h"

@interface BoardBoardListItem : AbstractDBBoardListItem
{
	unsigned boardID;
	NSString *name;
}

-(id)initWithBoardID:(unsigned)boardID;

-(unsigned)boardID;
-(void)setBoardID:(unsigned)boardID;

@end
