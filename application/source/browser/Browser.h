/**
  * $Id: Browser.h,v 1.9 2008/11/30 15:51:33 tsawada2 Exp $
  * 
  * Browser.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "CocoMonar_Prefix.h"
#import "CMRAbstructThreadDocument.h"

@class CMRThreadsList, BSDBThreadList;



@interface Browser : CMRAbstructThreadDocument
{
	@private
	BSDBThreadList			*m_currentThreadsList;
	NSString				*m_searchString;
}
- (NSURL *) boardURL;

- (BSDBThreadList *) currentThreadsList;
- (void) setCurrentThreadsList : (BSDBThreadList *) newList;

- (void) reloadThreadsList;


//- (BOOL) searchThreadsInListWithString : (NSString *) text;
//- (void) sortThreadsByKey : (NSString *) key;

//- (void) toggleThreadsListIsAscending;
//- (void) changeThreadsFilteringMask : (int) mask;

- (NSString *) searchString;
- (void) setSearchString: (NSString *) text;
- (BOOL) searchThreadsInListWithCurrentSearchString;

- (IBAction)toggleThreadsListViewMode:(id)sender;
- (IBAction)cleanupDatochiFiles:(id)sender;
- (IBAction)rebuildThreadsList:(id)sender; // Available in Tenori Tiger.
- (IBAction)newThread:(id)sender; // Available in SilverGull.
@end

/* for AppleScript */
@interface Browser(ScriptingSupport)
- (NSString *) boardURLAsString;

- (NSString *) boardNameAsString;
- (void) setBoardNameAsString : (NSString *) boardNameStr;

- (void)handleReloadListCommand:(NSScriptCommand*)command;
- (void)handleReloadThreadCommand:(NSScriptCommand*)command;
@end
