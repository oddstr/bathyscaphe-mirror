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
	NSString *representName;
}

- (id) initWithBoardID : (unsigned) boardID;
- (id) initWithURLString : (NSString *) urlString;

- (unsigned) boardID;
- (void) setBoardID : (unsigned) boardID;

@end
