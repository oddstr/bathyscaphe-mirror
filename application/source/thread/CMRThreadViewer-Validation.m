/*
    CMRThreadViewer-Validation.m
    CMRThreadViewer-Action.m から独立
    v1.0 - 2005-02-16 by tsawada2.
*/
#import "CMRThreadViewer_p.h"

#import "CMRThreadsList.h"
#import "CMRThreadView.h"
#import "CMRThreadVisibleRange.h"
#import "CMRThreadDownloadTask.h"
#import "CMXPopUpWindowManager.h"


//////////////////////////////////////////////////////////////////////
//////////////////// [ Define and Constants ] ////////////////////////
//////////////////////////////////////////////////////////////////////
#define kOnlineItemKey				@"On Line"
#define kOfflineItemKey				@"Off Line"
#define kOnlineItemImageName		@"online"
#define kOfflineItemImageName		@"offline"

#define kReplyItemKey				@"Reply..."
#define kReplyToItemKey				@"Reply 2..."

#define kAddFavaritesItemKey			@"Add Favorites"
#define kRemoveFavaritesItemKey			@"Remove Favorites"
#define kAddFavaritesItemImageName		@"AddFavorites"
#define kRemoveFavaritesItemImageName	@"RemoveFavorites"

#pragma mark -

@implementation CMRThreadViewer(Validation)

#pragma mark Action Menu

/*** アクション・メニュー ***/
#define kActionMenuItemTag				(100)	/* 「アクション」 */

#define kActionSpamHeader				(111)	/* 「迷惑レス」ヘッダ */
#define kActionAAHeader					(222)	/* 「AA」ヘッダ */
#define kActionBookmarkHeader			(333)	/* 「ブックマーク」ヘッダ */
#define kActionLocalAbonedHeader		(444)	/* 「ローカルあぼーん」ヘッダ */
#define kActionInvisibleAbonedHeader	(555)	/* 「透明あぼーん」ヘッダ */

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
	
	if (nil == contents_ || 0 == [contents_ length])
		return;
	
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

- (BOOL) validateUIItem : (id) theItem
{
	SEL		action_;
	NSDictionary	*selected_;
	BOOL		isSelected_;
	BOOL		isReallySelected_;
	BOOL		textSelected_;
	
	if (nil == theItem) return NO;
	if (NO == [theItem respondsToSelector : @selector(action)]) return NO;
	
	action_ = [theItem action];
	selected_ = [self selectedThread];
	isSelected_ = ([self selectedThreads] && [self numberOfSelectedThreads]);
	isReallySelected_ = ([[self selectedThreadsReallySelected] count] || [self threadURL]);
	textSelected_ = [[self textView] selectedRange].length != 0;
        
	// AA スレ
	if (@selector(toggleAAThread:) == action_) {
		[theItem setState : 
			([self isAAThread] ? NSOnState : NSOffState)];
		return isSelected_;
	}
	// オンライン
	if (@selector(toggleOnlineMode:) == action_) {
		NSString		*title_;
		NSImage			*image_;
		
		title_ = [CMRPref isOnlineMode]
					? [self localizedString : kOnlineItemKey]
					: [self localizedString : kOfflineItemKey];

		image_ = [CMRPref isOnlineMode]
					? [NSImage imageAppNamed : kOnlineItemImageName]
					: [NSImage imageAppNamed : kOfflineItemImageName];
		
		[theItem setImage : image_];
		[theItem setTitle : title_];
		return YES;
	}
	// レス
	if (action_ == @selector(reply:)) {
		NSString		*title_;
		
		title_ = (0 == ([[self textView] selectedRange]).length)
					? [self localizedString : kReplyItemKey]
					: [self localizedString : kReplyToItemKey];;
		
		[theItem setTitle : title_];		
		
		return (selected_ != nil && [self shouldShowContents]);
	}
	// お気に入りに追加
	if (action_ == @selector(addFavorites:)) {
		NSString				*title_;
		NSImage					*image_;
		CMRFavoritesOperation	operation_;
		
		if (NO == isSelected_) {
			return NO;
		}

		operation_ = [self favoritesOperationForThreads : [self selectedThreads]];
		if (CMRFavoritesOperationNone == operation_) {
			return NO;
		}

		title_ = (CMRFavoritesOperationLink == operation_)
					? [self localizedString : kAddFavaritesItemKey]
					: [self localizedString : kRemoveFavaritesItemKey];

		image_ = (CMRFavoritesOperationLink == operation_)
					? [NSImage imageAppNamed : kAddFavaritesItemImageName]
					: [NSImage imageAppNamed : kRemoveFavaritesItemImageName];
		
		[theItem setTitle : title_];
		if ([theItem image] != nil)
			[theItem setImage : image_];
		
		return YES;
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
	

	if (action_ == @selector(findNextText:)			||
	   action_ == @selector(findPreviousText:)		||
	   action_ == @selector(findFirstText:)			||
	   action_ == @selector(findAll:)				||
	   action_ == @selector(customizeBrdListTable:) ||
	   action_ == @selector(launchBWAgent:)			||
	   action_ == @selector(openDefaultNoNameInputPanel:)
	   )
	{ return YES; }
	
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

	if (action_ == @selector(showThreadWithMenuItem:))
		return YES;

	if (action_ == @selector(findTextInSelection:) ||
	   action_ == @selector(copySelectedResURL:)
	   )
	{ return textSelected_; }
	
	if (action_ == @selector(selectFirstVisibleRange:)	 ||
	   action_ == @selector(selectLastVisibleRange:)	 ||
	   action_ == @selector(reloadThread:)				 ||
	   action_ == @selector(copyURL:)					 ||
	   action_ == @selector(copyThreadAttributes:)		 ||
	   action_ == @selector(copyInfoFromContextualMenu:) ||
	   action_ == @selector(showThreadAttributes:)		 ||	  
	   action_ == @selector(deleteThread:)				 ||
	   action_ == @selector(openBBSInBrowser:) 
	   )
	{ return isSelected_; }
	
	if (action_ == @selector(openLogfile:)		||
	   action_ == @selector(openInBrowser:)		||
	   action_ == @selector(openSelectedThreads:)
	   )
	{ return isReallySelected_; }
	
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
	if (action_ == @selector(cancellCurrentTask:))
	{ 
		return [super validateToolbarItem : theItem];
	}
	if (NO == [super validateToolbarItem : theItem]) return NO;
	return [self validateUIItem : theItem];
}
@end
