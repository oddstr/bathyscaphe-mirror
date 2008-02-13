//:CMRAbstructThreadDocument.m
/**
  *
  * @see CMRThreadAttributes.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.9a2 (03/01/20  4:59:59 PM)
  *
  */
#import "CMRAbstructThreadDocument_p.h"
#import "CocoMonar_Prefix.h"
#import "BSThreadInfoPanelController.h"
#import "BSRelativeKeywordsCollector.h"
#import "BoardManager.h"
#import "missing.h"

NSString *const CMRAbstractThreadDocumentDidToggleDatOchiNotification = @"CMRAbstractThreadDocumentDidToggleDatOchiNotification";

@implementation CMRAbstructThreadDocument
- (void) replace : (CMRThreadAttributes *) oldAttributes
			with : (CMRThreadAttributes *) newAttributes
{
	//
	// for subclass
	//
}

- (BOOL) windowAlreadyExistsForPath : (NSString *) filePath
{
	/* 2005-09-15 tsawada2 <ben-sawa@td5.so-net.ne.jp>
	このメソッドはスレッドを履歴メニューなどから切り替える直前に呼ばれる。
	パラメータには、これから切り替えようとしている（切り替え先の）スレッドのファイルパスを与える。
	
	ファイルパスを基に NSDocument を探す。見つかれば、もうそのドキュメントが開かれている訳だから、
	切り替えを中止し、かわりにそのドキュメントのウインドウをアクティブに。
	
	見つからなければ、切り替えの許可、return YES;。*/
	NSDocumentController	*dc_;
	NSDocument				*document_;
	
	if (nil == filePath) return NO;

	dc_ = [NSDocumentController sharedDocumentController];
	document_ = [dc_ documentForFileName : filePath];
	
	if (nil == document_) {
		return NO;
	} else {
		[document_ showWindows];
		return YES;
	}
}

#pragma mark Accessors
- (NSTextStorage *) textStorage
{
	if(nil == _textStorage) {
		_textStorage = [[NSTextStorage alloc] init];
	}
	return _textStorage;
}
- (void) setTextStorage : (NSTextStorage *) aTextStorage
{
	id		tmp;
	
	tmp = _textStorage;
	_textStorage = [aTextStorage retain];
	[tmp release];
}

- (CMRThreadAttributes *) threadAttributes
{
	return _threadAttributes;
}
- (void) setThreadAttributes : (CMRThreadAttributes *) newAttributes
{
	CMRThreadAttributes		*oldAttributes_;
	
	oldAttributes_ = _threadAttributes;
	_threadAttributes = [newAttributes retain];	
	
	[self replace:oldAttributes_ with:newAttributes];
	
	[oldAttributes_ release];
}
- (NSArray *) cachedKeywords
{
	return m_keywords;
}
- (void) setCachedKeywords: (NSArray *) array
{
	[array retain];
	[m_keywords release];
	m_keywords = array;
}
- (BSRelativeKeywordsCollector *) keywordsCollector
{
	if (m_collector == nil) {
		m_collector = [[BSRelativeKeywordsCollector alloc] init];
	}
	return m_collector;
}
- (BOOL) isAAThread
{
	return [[self threadAttributes] isAAThread];
}
- (void) setIsAAThread : (BOOL) flag
{
	if ([self isAAThread] == flag)
		return;
	
	NSArray *winControllers;
	[[self threadAttributes] setIsAAThread : flag];
	winControllers = [self windowControllers];
	if ([winControllers count] > 0) {
		[winControllers makeObjectsPerformSelector: @selector(changeAllMessageAttributesWithAAFlag:)
										withObject: [NSNumber numberWithBool: flag]];
	}
}

- (BOOL) isDatOchiThread
{
	return [[self threadAttributes] isDatOchiThread];
}
- (void) setIsDatOchiThread : (BOOL) flag
{
	if ([self isDatOchiThread] == flag)
		return;
	
	[[self threadAttributes] setIsDatOchiThread : flag];
	NSDictionary *foo = [NSDictionary dictionaryWithObject:[[self threadAttributes] path] forKey:@"path"];
	UTILNotifyInfo(CMRAbstractThreadDocumentDidToggleDatOchiNotification, foo);
}

- (BOOL) isMarkedThread
{
	return [[self threadAttributes] isMarkedThread];
}
- (void) setIsMarkedThread : (BOOL) flag
{
	if ([self isMarkedThread] == flag)
		return;
	
	[[self threadAttributes] setIsMarkedThread : flag];
}

#pragma mark Override
- (void) dealloc
{
	[m_collector release];
	[m_keywords release];
	[_threadAttributes release];
	[_textStorage release];
	[super dealloc];
}

- (void) removeWindowController : (NSWindowController *) windowController
{
	NSEnumerator		*iter_;
	NSWindowController	*controller_;
	SEL					selector_;
	
	selector_ = @selector(document:willRemoveController:);
	iter_ = [[self windowControllers] objectEnumerator];
	
	while(controller_ = [iter_ nextObject]){
		if(NO == [controller_ respondsToSelector : selector_])
			continue;
		
		[controller_ document:self willRemoveController:windowController];
	}
	if ([[self keywordsCollector] delegate] == windowController) {
//		NSLog(@"ThreadViewer - document's delegate is self, but self is going to dealloc, so set delegate to nil.");
		[[self keywordsCollector] setDelegate: nil];
	}

	[super removeWindowController : windowController];
}

#pragma mark Validation
- (BOOL) validateUserInterfaceItem: (id <NSObject, NSValidatedUserInterfaceItem>) theItem
{
	SEL action_;

	action_ = [theItem action];
	
	if (action_ == @selector(showDocumentInfo:) || action_ == @selector(showMainBrowser:)) {
		return ([self threadAttributes] != nil);
	}

	if (action_ == @selector(saveDocumentAs:) && [theItem respondsToSelector: @selector(setTitle:)]) {
		[theItem setTitle : NSLocalizedString(@"Save Menu Item Default", @"Save as...")];
	} else if (action_ == @selector(toggleAAThread:)) {
		if ([self threadAttributes] == nil) return NO;
		if ([theItem respondsToSelector: @selector(setState:)]) [theItem setState: ([self isAAThread] ? NSOnState : NSOffState)];
	} else if (action_ == @selector(toggleMarkedThread:)) {
		if ([self threadAttributes] == nil) return NO;
		if ([theItem respondsToSelector: @selector(setState:)]) [theItem setState: ([self isMarkedThread] ? NSOnState : NSOffState)];
	} else if (action_ == @selector(toggleDatOchiThread:)) {
		if ([self threadAttributes] == nil) return NO;
		if ([theItem respondsToSelector: @selector(setState:)]) [theItem setState: ([self isDatOchiThread] ? NSOnState : NSOffState)];
	} else if (action_ == @selector(showLocalRules:)) {
		BoardManager *bm = [BoardManager defaultManager];
		if (![bm canUseLocalRulesPanel]) return NO;
		if ([theItem respondsToSelector:@selector(setTitle:)]) {
			[theItem setTitle:[bm isKeyWindowForBoardName:[self boardNameAsString]] ? NSLocalizedString(@"Hide Local Rules", @"")
																					: NSLocalizedString(@"Show Local Rules", @"")];
		}
		return YES;
	}
	return [super validateUserInterfaceItem: theItem];
}

#pragma mark IBActions
- (IBAction) showDocumentInfo: (id) sender
{
	[[BSThreadInfoPanelController sharedInstance] showWindow: sender];
}

- (IBAction) showMainBrowser: (id) sender
{
	CMRThreadAttributes *attr_ = [self threadAttributes];
	NSString *boardName_ = [attr_ boardName];
	if(!boardName_) return; 

	[[NSApp delegate] showThreadsListForBoard: boardName_ selectThread: [attr_ path] addToListIfNeeded: YES];
}

- (IBAction)revealInFinder:(id)sender
{
	NSString *path = [[self threadAttributes] path];
	if (!path) {
		NSBeep();
		return;
	}
	[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:[path stringByDeletingLastPathComponent]];
}

- (IBAction) toggleAAThread: (id) sender
{
	[self setIsAAThread: ![self isAAThread]];
}

- (IBAction) toggleDatOchiThread: (id) sender
{
	[self setIsDatOchiThread: ![self isDatOchiThread]];
}

- (IBAction) toggleMarkedThread: (id) sender
{
	[self setIsMarkedThread: ![self isMarkedThread]];
}

- (IBAction) toggleAAThreadFromInfoPanel: (id) sender
{
	NSArray *winControllers;
	BOOL	flag = [self isAAThread];
	winControllers = [self windowControllers];
	if ([winControllers count] > 0) {
		[winControllers makeObjectsPerformSelector: @selector(changeAllMessageAttributesWithAAFlag:)
										withObject: [NSNumber numberWithBool: flag]];
	}
}

- (IBAction)showLocalRules:(id)sender
{
	id foo = [[BoardManager defaultManager] localRulesPanelControllerForBoardName:[self boardNameAsString]];
	[foo showWindow:self];
}
@end

#pragma mark -
@implementation CMRAbstructThreadDocument(ScriptingSupport)
- (NSTextStorage *) selectedText
{
	NSAttributedString* attrString;
	attrString = [[self textStorage] attributedSubstringFromRange:[[[[self windowControllers] lastObject] textView] selectedRange]];
	NSTextStorage * storage = [[NSTextStorage alloc] initWithAttributedString:attrString];
	return [storage autorelease];
}

- (NSDictionary *) threadAttrDict
{
	return [[self threadAttributes] dictionaryRepresentation];
}
- (NSString *) threadTitleAsString
{
	return [[self threadAttributes] threadTitle];
}

- (NSString *) threadURLAsString
{
	return [[[self threadAttributes] threadURL] stringValue];
}
- (NSString *) boardNameAsString
{
	return [[self threadAttributes] boardName];
}
- (NSString *) boardURLAsString
{
	return [[[self threadAttributes] boardURL] stringValue];
}

- (void)handleReloadThreadCommand:(NSScriptCommand*)command
{
	[[[self windowControllers] lastObject] reloadThread : nil];
}
@end
