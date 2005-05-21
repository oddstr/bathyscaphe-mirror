/**
  * $Id: Browser.m,v 1.2 2005/05/21 10:43:03 tsawada2 Exp $
  * 
  * Browser.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "Browser.h"

#import "CMXPreferences.h"
#import "CMRBrowser_p.h"
#import "CMRThreadsList.h"
#import "CMRThreadAttributes.h"
#import "CMRThreadViewer_p.h"
#import "CMRHistoryManager.h"

#import "CMRBrowserTemplateKeys.h"

#import "BoardManager.h"
#import "BoardList.h"
#import "CMRSearchOptions.h"



@implementation Browser
- (void) dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[self setCurrentThreadsList : nil];
	[self setThreadAttributes : nil];
	
	[super dealloc];
}
- (NSURL *) boardURL
{
	return [[self currentThreadsList] boardURL];
}

- (CMRThreadsList *) currentThreadsList
{
	return m_currentThreadsList;
}
- (void) setCurrentThreadsList : (CMRThreadsList *) aCurrentThreadsList
{
	id tmp;
	
	tmp = m_currentThreadsList;
	m_currentThreadsList = [aCurrentThreadsList retain];
	[tmp release];
}

- (void) reloadThreadsList
{
	[[self currentThreadsList] downloadThreadsList];
}


//////////////////////////////////////////////////////////////////////
///////////////////////// [ NSDocument ] /////////////////////////////
//////////////////////////////////////////////////////////////////////
- (void) makeWindowControllers
{
	CMRBrowser		*browser_;
	
	browser_ = [[CMRBrowser alloc] init];
	[self addWindowController : browser_];
	[browser_ release];
}
- (NSString *) displayName
{
	CMRThreadsList		*list_;
	
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
- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	SEL action_;

	action_ = [theItem action];
	
	if(action_ == @selector(saveDocument:) || action_ == @selector(saveDocumentAs:)) 
		return NO;
		
	return [super validateMenuItem : theItem];
}


//////////////////////////////////////////////////////////////////////
//////////////////////// [ �X���b�h�ꗗ ] ////////////////////////////
//////////////////////////////////////////////////////////////////////
- (BOOL) searchThreadsInListWithString : (NSString *) text
{
	CMRSearchOptions		*operation_;
	unsigned int		options_ = 0;

	CMRSearchMask		searchOption_;
	NSNumber			*info_;
	
	//id	tmp;
	
	if(nil == [self currentThreadsList]) return NO;
	if(nil == text || [text isEmpty]) return NO;
	
	
	searchOption_ = [CMRPref threadSearchOption];
	if(CMRSearchOptionCaseInsensitive & searchOption_)
		options_ |= NSCaseInsensitiveSearch;
	if(CMRSearchOptionBackwards & searchOption_)
		options_ |= NSBackwardsSearch;
	
	info_ = [NSNumber numberWithUnsignedInt : searchOption_];
	operation_   = [CMRSearchOptions operationWithFindObject : text
								           replace : nil
								          userInfo : info_
								            option : options_];
	
	/*
	// Incremental Search �̏ꍇ�͗����ɓo�^���Ȃ�
    tmp = SGTemplateResource(kBrowserIncrementalSearchKey);
    UTILAssertRespondsTo(tmp, @selector(boolValue));
    if(NO == [tmp boolValue]){
		// �����ɓo�^
		[[CMRHistoryManager defaultManager]
			addItemWithTitle : text
			type : CMRHistorySearchListOptionEntryType
			object : operation_];
	}
	*/
	return [[self currentThreadsList] filterByFindOperation : operation_];
}

- (void) sortThreadsByKey : (NSString *) key
{
	//�\�[�g�E�L�[��AppDefaults�ŋ��L�@�c���Ȃ��i1.0.9.7 �ȍ~�j
	//[CMRPref setBrowserSortColumnIdentifier : key];
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

/* for AppleScript */
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
	CMRBBSSignature		*signature_;
	
	signature_ = [CMRBBSSignature BBSSignatureWithName : boardNameStr];
	//CMRMainBrowser �́A���݂̃��C���E�u���E�U�̃C���X�^���X�B(see CMRBrowser.m)
	[CMRMainBrowser showThreadsListWithBBSSignature : signature_];
	//�f�����X�g�̑I���s������������������
	[CMRMainBrowser selectRowWhoseNameIs : boardNameStr];
}

- (void)handleReloadListCommand:(NSScriptCommand*)command
{
	[self reloadThreadsList];
}
- (void)handleReloadThreadCommand:(NSScriptCommand*)command
{
	[CMRMainBrowser reloadThread : nil];
}
@end