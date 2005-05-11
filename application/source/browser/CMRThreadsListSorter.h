/**
  * $Id: CMRThreadsListSorter.h,v 1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadsListSorter.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>



@class SGTextAccessoryFieldController;

@interface CMRThreadsListSorter : NSObject
{
	IBOutlet NSView					*_view;
	IBOutlet NSPopUpButton			*_searchPopUp;
	SGTextAccessoryFieldController	*_searchItemController;
}
@end



@interface CMRThreadsListSorter(ViewAccessor)
- (NSView *) componentView;
- (NSView *) searchView;
- (NSPopUpButton *) searchPopUp;
- (NSTextField *) searchTextField;
- (SGTextAccessoryFieldController *) searchItemController;
@end


// menuItem tags
#define kSearchPopUpOptionItemTag			11
#define kSearchPopUpSeparatorTag			22
#define kSearchPopUpHistoryHeaderItemTag	33
#define kSearchPopUpHistoryItemTag			44
