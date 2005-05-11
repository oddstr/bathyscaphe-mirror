/**
  * $Id: CMRSplitView.h,v 1.1.1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * CMRSplitView.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import <SGAppKit/SGAppKit.h>
#import "KFSplitView.h"

@interface CMRSplitView : KFSplitView
/*
@interface CMRSplitView : SGSplitView
{
	NSString		*_frameAutosaveName;
}

- (NSString *) frameAutosaveName;
- (BOOL) setFrameAutosaveName : (NSString *) name;

- (BOOL) setFrameUsingName : (NSString *) name;
- (void) setFrameFromArray : (NSArray *) frameArray;
- (NSArray *) arrayFromSavedName : (NSString *) name;

+ (void) removeFrameUsingName : (NSString *) name;
- (void) saveFrameUsingName : (NSString *) name;
- (NSArray *) arrayWithSavedFrame;
*/

- (void)kfSetupResizeCursors;
@end
