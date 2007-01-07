/**
  * $Id: Browser.m,v 1.17 2007/01/07 17:04:23 masakih Exp $
  * BathyScaphe 
  *
  * Copyright 2005-2006 BathyScaphe Project.
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "Browser.h"

#import "AppDefaults.h"
#import "CMRThreadViewer_p.h"
#import "CMRBrowser_p.h"
#import "CMRThreadsList.h"
#import "CMRThreadAttributes.h"

#import "BoardManager.h"
// #import "BoardList.h"


@implementation Browser
- (void) dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[self setCurrentThreadsList : nil];
	[self setThreadAttributes : nil];
	[m_searchString release];
	
	[super dealloc];
}

- (NSURL *) boardURL
{
	return [[self currentThreadsList] boardURL];
}

- (BSDBThreadList *) currentThreadsList
{
	return m_currentThreadsList;
}

- (void) setCurrentThreadsList : (BSDBThreadList *) aCurrentThreadsList
{
	id tmp;
	
	tmp = m_currentThreadsList;
	m_currentThreadsList = [aCurrentThreadsList retain];
	[tmp release];
}

- (NSString *) searchString
{
	return m_searchString;
}

- (void) setSearchString: (NSString *) text
{
	[text retain];
	[m_searchString release];
	m_searchString = text;
}

#pragma mark NSDocument

- (void) makeWindowControllers
{
	CMRBrowser		*browser_;
	
	browser_ = [[CMRBrowser alloc] init];
	[self addWindowController : browser_];
	[browser_ release];
}

- (NSString *) displayName
{
	BSDBThreadList		*list_;
	
	list_ = [self currentThreadsList];
	return list_ ? [list_ boardName] : nil;
}

- (BOOL) readFromFile : (NSString *) fileName
			   ofType : (NSString *) type
{
	return YES;
}

- (BOOL) loadDataRepresentation : (NSData   *) data
                         ofType : (NSString *) aType
{
	return NO;
}

- (NSData *) dataRepresentationOfType : (NSString *) aType
{
	return nil;
}

- (IBAction) saveDocumentAs : (id) sender
{
	if ([self threadAttributes] == nil) return;

	NSFileManager	*fM_ = [NSFileManager defaultManager];
	NSString *filePath_ = [[self threadAttributes] path];
	if (filePath_ == nil || NO == [fM_ fileExistsAtPath: filePath_]) return;

	NSSavePanel *savePanel_ = [NSSavePanel savePanel];
	int			resultCode;

	[savePanel_ setRequiredFileType : CMRThreadDocumentPathExtension];
	[savePanel_ setCanCreateDirectories : YES];
	[savePanel_ setCanSelectHiddenExtension : YES];

	resultCode = [savePanel_ runModalForDirectory: nil file: [filePath_ lastPathComponent]];

	if (resultCode == NSFileHandlingPanelOKButton) {
		NSString *savePath_ = [savePanel_ filename];
		if ([fM_ copyPath: filePath_ toPath: savePath_ handler: nil]) {
			NSDate	*curDate_ = [NSDate date];
			NSDictionary *tmp_;
			tmp_ = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool: [savePanel_ isExtensionHidden]], NSFileExtensionHidden,
															   curDate_, NSFileModificationDate, curDate_, NSFileCreationDate, NULL];
			[fM_ changeFileAttributes: tmp_ atPath: savePath_];
		} else {
			NSBeep();
			NSLog(@"Save failure - %@", savePath_);
		}
	}
}

- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	SEL action_;

	action_ = [theItem action];
	
	if(action_ == @selector(saveDocumentAs:)) {
		[theItem setTitle : NSLocalizedString(@"Save Menu Item Default", @"Save as...")];
		return ([self threadAttributes] != nil);
	}	
	return [super validateMenuItem : theItem];
}

#pragma mark ThreadsList

- (void) reloadThreadsList
{
	[[self currentThreadsList] downloadThreadsList];
}

- (BOOL) searchThreadsInListWithCurrentSearchString
{
	if(nil == [self currentThreadsList]) return NO;

	return [[self currentThreadsList] filterByString: [self searchString]];
}

- (BOOL) searchThreadsInListWithString : (NSString *) text
{
	if(nil == [self currentThreadsList]) return NO;

	return [[self currentThreadsList] filterByString: text];
}

- (void) sortThreadsByKey : (NSString *) key
{
	[[self currentThreadsList] sortByKey : key];
}

- (void) toggleThreadsListIsAscending
{
	if(nil == [self currentThreadsList]) return;
	[[self currentThreadsList] toggleIsAscending];
}

- (void) changeThreadsFilteringMask : (int) mask
{
	if(nil == [self currentThreadsList]) return;
	[[self currentThreadsList] setFilteringMask : mask];
	[[self currentThreadsList] filterByStatus : mask];
}
@end

#pragma mark -

@implementation Browser(ScriptingSupport)
- (NSString *) boardURLAsString
{
	return [[self boardURL] stringValue];
}

- (NSString *) boardNameAsString
{
	return [[self currentThreadsList] boardName];
}

- (void) setBoardNameAsString : (NSString *) boardNameStr
{
	CMRBrowser *wc_ = [[self windowControllers] lastObject];
	if (wc_ == nil) return;

	[wc_ showThreadsListWithBoardName : boardNameStr];
	[wc_ selectRowWhoseNameIs : boardNameStr];
}

- (void) handleReloadListCommand : (NSScriptCommand *) command
{
	[self reloadThreadsList];
}

- (void) handleReloadThreadCommand : (NSScriptCommand *) command
{
	CMRBrowser *wc_ = [[self windowControllers] lastObject];
	if (wc_ == nil) return;

	[wc_ reloadThread : nil];
}
@end
