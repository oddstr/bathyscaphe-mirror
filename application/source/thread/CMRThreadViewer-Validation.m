/*
    $Id: CMRThreadViewer-Validation.m,v 1.29 2007/03/18 17:46:52 tsawada2 Exp $
    CMRThreadViewer-Action.m から独立
    Created at 2005-02-16 by tsawada2.
*/
#import "CMRThreadViewer_p.h"

#import "CMRThreadsList.h"
#import "CMRThreadView.h"
#import "CMRThreadVisibleRange.h"
#import "CMRThreadLayout.h"
#import "CMXPopUpWindowManager.h"
#import "BSBoardInfoInspector.h"

//////////////////////////////////////////////////////////////////////
#pragma mark Define and Constants
//////////////////////////////////////////////////////////////////////
#define kReplyItemKey				@"Reply..."
#define kReplyToItemKey				@"Reply 2..."

#define kAddFavaritesItemKey			@"Add Favorites"
#define kRemoveFavaritesItemKey			@"Remove Favorites"
#define kAddFavaritesItemImageName		@"AddFavorites"
#define kRemoveFavaritesItemImageName	@"RemoveFavorites"

#define kDeleteWithoutAlertKey			@"Delete Log"
#define kDeleteWithAlertKey				@"Delete Log..."

/*** アクション・メニュー ***/
#define kActionMenuItemTag				(100)	/* 「アクション」 */

#define kActionSpamHeader				(111)	/* 「迷惑レス」ヘッダ */
#define kActionAAHeader					(222)	/* 「AA」ヘッダ */
#define kActionBookmarkHeader			(333)	/* 「ブックマーク」ヘッダ */
#define kActionLocalAbonedHeader		(444)	/* 「ローカルあぼーん」ヘッダ */
#define kActionInvisibleAbonedHeader	(555)	/* 「透明あぼーん」ヘッダ */

#pragma mark -

@implementation CMRThreadViewer(Validation)

#pragma mark Action Menu


- (IBAction) actionMenuHeader : (id) sender
{
}
/*** レス属性 ***/
static int messageMaskForTag(int tag)
{
	if (kActionInvisibleAbonedHeader <= tag) {
		return CMRInvisibleAbonedMask;
	} else if (kActionLocalAbonedHeader <= tag) {
		return CMRLocalAbonedMask;
	} else if (kActionBookmarkHeader <= tag) {
		return CMRBookmarkMask;
	} else if (kActionAAHeader <= tag) {
		return CMRAsciiArtMask;
	} else if (kActionSpamHeader <= tag) {
		return CMRSpamMask;
	} 
	return 0;
}
- (IBAction) clearMessageAttributes : (id) sender
{
	[[self threadLayout]
		changeAllMessageAttributes : NO
							 flags : messageMaskForTag([sender tag])];
}
- (IBAction) setOnMessageAttributes : (id) sender
{
	[[self threadLayout]
		changeAllMessageAttributes : YES
							 flags : messageMaskForTag([sender tag])];
}
- (IBAction) showMessageMatchesAttributes : (id) sender
{
	NSRange				indexRange_;
	NSAttributedString	*contents_;
	NSPoint				location_;
	unsigned			composingMask_;
	unsigned			attributeMask_ = CMRAnyAttributesMask;
	
	composingMask_ = messageMaskForTag([sender tag]);
	// ブックマーク、ＡＡ以外の属性は無視する
	attributeMask_ &= ~CMRBookmarkMask;
	attributeMask_ &= ~CMRAsciiArtMask;
	
	indexRange_ = NSMakeRange(0, [[self threadLayout] firstUnlaidMessageIndex]);
	if (0 == indexRange_.length)
		return;
	
	contents_ = [[self threadLayout] contentsForIndexRange : indexRange_
	 					 composingMask : composingMask_
							   compose : YES
						attributesMask : attributeMask_];
	
	if (nil == contents_ || 0 == [contents_ length]) {
		NSBeep();
		return;
	}
	location_ = [self locationForInformationPopUp];
	[CMRPopUpMgr showPopUpWindowWithContext : contents_
								  forObject : [self threadIdentifier]
									  owner : self
							   locationHint : location_];
}

#pragma mark Validation

- (BOOL) validateActionMenuItem : (NSMenuItem *) theItem
{
	int			tag = [theItem tag];
	SEL			action = [theItem action];
	unsigned	mask;
	
	if (@selector(runSpamFilter:) == action)
		return YES;
	
	mask = messageMaskForTag(tag);
	if (mask != 0) {
		unsigned	nMatches;		

		nMatches = [[self threadLayout] numberOfMessageAttributes : mask];

		{
			NSString	*title_ = @"";
			NSString	*key_   = nil;
			
			if (kActionSpamHeader == tag) {
				key_ = @"ActionSpamHeaderFormat";
			} else if (kActionAAHeader == tag) {
				key_ = @"ActionAAHeaderFormat";
			} else if (kActionBookmarkHeader == tag) {
				key_ = @"ActionBookmarkHeaderFormat";
			} else if (kActionLocalAbonedHeader == tag) {
				key_ = @"ActionLocalAbonedHeaderFormat";
			} else if (kActionInvisibleAbonedHeader == tag) {
				key_ = @"ActionInvisibleAbonedHeaderFormat";
			}
			if (key_ != nil) {
				// ヘッダ
				title_ = [self localizedString : key_];
				title_ = [NSString stringWithFormat : title_, nMatches];
				[theItem setTitle : title_];
			}
		}
		
		if ( @selector(clearMessageAttributes:) == action || 
			 @selector(showMessageMatchesAttributes:) == action )
		{
			return (nMatches != 0);
		}
		
		// すべてのレスを変更
		if (@selector(setOnMessageAttributes:) == action) {
			unsigned nReaded = [[self threadLayout] numberOfReadedMessages];
			
			if (0 == nReaded) return NO;
			
			return (nReaded > nMatches);
		}
	}
	return NO;
}

- (void) validateDeleteThreadItemTitle: (id) theItem
{
	if ([theItem isKindOfClass: [NSMenuItem class]]) {
		[theItem setTitle: [CMRPref quietDeletion] ? [self localizedString: kDeleteWithoutAlertKey] : [self localizedString: kDeleteWithAlertKey]];
	}
}

- (BOOL) validateDeleteThreadItemEnabling: (NSString *) threadPath
{
	if (threadPath && [[NSFileManager defaultManager] fileExistsAtPath: threadPath]) {
		return YES;
	} else {
		return NO;
	}
}

- (CMRFavoritesOperation) favoritesOperationForThreads: (NSArray *) threadsArray
{
	NSDictionary	*thread_;
	NSString		*path_;
	
	if (nil == threadsArray || 0 == [threadsArray count])
		return CMRFavoritesOperationNone;
	
	thread_ = [threadsArray objectAtIndex : 0];
	path_ = [CMRThreadAttributes pathFromDictionary : thread_];

	UTILAssertNotNil(path_);
	
	return [[CMRFavoritesManager defaultManager] availableOperationWithPath: path_];
}

- (BOOL) validateAddFavoritesItem: (id) theItem forOperation: (CMRFavoritesOperation) operation
{
	NSString				*title_;
	NSImage					*image_;

	if (CMRFavoritesOperationNone == operation) {
		return NO;
	}

	title_ = (CMRFavoritesOperationLink == operation)
				? [self localizedString: kAddFavaritesItemKey]
				: [self localizedString: kRemoveFavaritesItemKey];

	image_ = (CMRFavoritesOperationLink == operation)
				? [NSImage imageAppNamed: kAddFavaritesItemImageName]
				: [NSImage imageAppNamed: kRemoveFavaritesItemImageName];
	
	[theItem setTitle: title_];
	if ([theItem image] != nil) [theItem setImage: image_];
	
	return YES;
}

- (BOOL) validateUIItem : (id) theItem
{
	SEL		action_;
	BOOL	isSelected_;
	
	if (nil == theItem) return NO;
	
	action_ = [theItem action];
	isSelected_ = ([self selectedThreads] && [self numberOfSelectedThreads]);
        
	// 印を付ける
	/*if (@selector(toggleAAThread:) == action_) {
		[theItem setState : ([self isAAThread] ? NSOnState : NSOffState)];
		return isSelected_;
	}*/

	// レス
	if (action_ == @selector(reply:)) {
		NSString		*title_;
		
		title_ = (0 == ([[self textView] selectedRange]).length)
					? [self localizedString : kReplyItemKey]
					: [self localizedString : kReplyToItemKey];
		
		[theItem setTitle : title_];		
		
		return ([self threadAttributes] && [self shouldShowContents]);
	}

	// お気に入りに追加
	if (action_ == @selector(addFavorites:)) {
		return [self validateAddFavoritesItem: theItem forOperation: [self favoritesOperationForThreads: [self selectedThreads]]];
	}

	// ログを削除(...)
	if (action_ == @selector(deleteThread:)) {
		[self validateDeleteThreadItemTitle: theItem];
		return [self validateDeleteThreadItemEnabling: [self path]];
	}
	
	// 移動
	if (action_ == @selector(scrollFirstMessage:))
		return [self canScrollFirstMessage];
	if (action_ == @selector(scrollLastMessage:))
		return [self canScrollLastMessage];
	if (action_ == @selector(scrollPrevMessage:))
		return [self canScrollPrevMessage];
	if (action_ == @selector(scrollNextMessage:))
		return [self canScrollNextMessage];
	if (action_ == @selector(scrollToLastReadedIndex:)) 
		return [self canScrollToLastReadedMessage];
	if (action_ == @selector(scrollToLastUpdatedIndex:)) 
		return [self canScrollToLastUpdatedMessage];
	// ブックマークに移動
	if (action_ == @selector(scrollPreviousBookmark:)) 
		return ([[self threadLayout] previousBookmarkIndex] != NSNotFound);
	if (action_ == @selector(scrollNextBookmark:)) 
		return ([[self threadLayout] nextBookmarkIndex] != NSNotFound);
	if (action_ == @selector(scrollToFirstTodayMessage:))
		return [self canScrollToMessage]; // とりあえず
	
	// 常に使えるアイテムたち
	if (action_ == @selector(findNextText:)		||
	   action_ == @selector(findPreviousText:)	||
	   action_ == @selector(findFirstText:)		||
	   action_ == @selector(findAll:)			||
	   action_ == @selector(findAllByFilter:) ||
		action_ == @selector(biggerText:) ||
	   action_ == @selector(smallerText:) ||
	   action_ == @selector(scaleSegmentedControlPushed:)) // For Segmented Control
	{ return [self shouldShowContents] && [[[self textView] textStorage] length]; }

	if (action_ == @selector(showBoardInspectorPanel:)) {
		NSWindowController *wc_ = [BSBoardInfoInspector sharedInstance];
		if (NO == [wc_ isWindowLoaded]) {
			[theItem setTitle: NSLocalizedString(@"Show Board Inspector", @"Hide Board Options")];
		} else {
			BOOL tmpBool = [[wc_ window] isVisible];
			[theItem setTitle : (tmpBool ? NSLocalizedString(@"Hide Board Inspector", @"Show Board Options")
										 : NSLocalizedString(@"Show Board Inspector", @"Hide Board Options"))];
		}
		return YES;
	}
	
	// 履歴：戻る／進む
	if (action_ == @selector(historyMenuPerformForward:)) {
		if([self shouldShowContents]) {
			return ([self threadIdentifierFromHistoryWithRelativeIndex : 1] != nil);
		} else {
			return NO;
		}
	}

	if (action_ == @selector(historyMenuPerformBack:)) {
		if([self shouldShowContents]) {
			return ([self threadIdentifierFromHistoryWithRelativeIndex : -1] != nil);
		} else {
			return NO;
		}
	}

	// 選択テキストの検索／コビー
	if (action_ == @selector(findTextInSelection:) ||
	   action_ == @selector(copySelectedResURL:)
	   )
	{ return ([[self textView] selectedRange].length != 0); }
	
	if (action_ == @selector(copyURL:)					 ||
	   action_ == @selector(copyThreadAttributes:)		 ||
	   action_ == @selector(openBBSInBrowser:) 
	   )
	{ return isSelected_; }
	
	if (action_ == @selector(reloadThread:))
		return ([self threadAttributes] && ![self isDatOchiThread]);
	
	if (action_ == @selector(openInBrowser:)/* || action_ == @selector(openSelectedThreads:)*/) {
		return ([[self selectedThreadsReallySelected] count] || [self threadURL]);
	}

	return NO;
}

- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	if ([super validateMenuItem : theItem]) 
		return YES;
	
	if (NO ==  [self validateUIItem : theItem])
		return [self validateActionMenuItem : theItem];
	
	return YES;
}

- (BOOL) validateToolbarItem : (NSToolbarItem *) theItem
{
	SEL action_ = [theItem action];
	if (action_ == @selector(cancelCurrentTask:))
	{ 
		return [super validateToolbarItem : theItem];
	}
	if (NO == [super validateToolbarItem : theItem]) return NO;
	return [self validateUIItem : theItem];
}
@end
