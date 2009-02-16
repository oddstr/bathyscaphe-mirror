//
//  Browser.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 09/02/17.
//  Copyright 2005-2009 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import "CocoMonar_Prefix.h"
#import "CMRAbstructThreadDocument.h"

@class CMRThreadsList, BSDBThreadList;

@interface Browser : CMRAbstructThreadDocument {
	@private
	BSDBThreadList			*m_currentThreadsList;
	NSString				*m_searchString;

	// Tenori Tiger Additions
	// データベース再構築中のモーダルパネル
	IBOutlet NSProgressIndicator	*m_fakeIndicator;
	IBOutlet NSWindow				*m_modalWindow;
}

- (NSURL *)boardURL;

- (BSDBThreadList *)currentThreadsList;
- (void)setCurrentThreadsList:(BSDBThreadList *)newList;

- (void)reloadThreadsList;

- (NSString *)searchString;
- (void)setSearchString:(NSString *)text;

- (BOOL)searchThreadsInListWithCurrentSearchString;

- (IBAction)toggleThreadsListViewMode:(id)sender;
- (IBAction)cleanupDatochiFiles:(id)sender;
- (IBAction)rebuildThreadsList:(id)sender; // Available in Tenori Tiger.
- (IBAction)newThread:(id)sender; // Available in SilverGull.
@end

/* for AppleScript */
@interface Browser(ScriptingSupport)
- (NSString *)boardURLAsString;

- (NSString *)boardNameAsString;
- (void)setBoardNameAsString:(NSString *)boardNameStr;

- (void)handleReloadListCommand:(NSScriptCommand*)command;
- (void)handleReloadThreadCommand:(NSScriptCommand*)command;
@end
