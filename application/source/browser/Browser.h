/**
  * $Id: Browser.h,v 1.1 2005/05/11 17:51:03 tsawada2 Exp $
  * 
  * Browser.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "CocoMonar_Prefix.h"
#import "CMRAbstructThreadDocument.h"

@class CMRThreadsList;



@interface Browser : CMRAbstructThreadDocument
{
	@private
	CMRThreadsList			*m_currentThreadsList;
}
- (NSURL *) boardURL;

- (CMRThreadsList *) currentThreadsList;
- (void) setCurrentThreadsList : (CMRThreadsList *) newList;

- (void) reloadThreadsList;


- (BOOL) searchThreadsInListWithString : (NSString *) text;
- (void) sortThreadsByKey : (NSString *) key;

- (void) toggleThreadsListIsAscending;
- (void) changeThreadsFilteringMask : (int) mask;
@end

/* for AppleScript */
@interface Browser(ScriptingSupport)
- (NSString *) boardURLAsString;

- (NSString *) boardNameAsString;
- (void) setBoardNameAsString : (NSString *) boardNameStr;

- (void)handleReloadListCommand:(NSScriptCommand*)command;
- (void)handleReloadThreadCommand:(NSScriptCommand*)command;
@end
