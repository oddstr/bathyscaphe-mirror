/** 
  * $Id: CMRThreadViewer-Find.m,v 1.12 2007/03/15 02:35:16 tsawada2 Exp $
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * CMRThreadViewer-Action.m から分割 - 2005-02-16 by tsawada2.
  */
#import "CMRThreadViewer_p.h"

#import "CMRThreadsList.h"
#import "SGLinkCommand.h"
#import "CMRReplyMessenger.h"
#import "CMRReplyDocumentFileManager.h"
#import "CMRThreadVisibleRange.h"
#import "CMRThreadLayout.h"

#import "CMRSearchOptions.h"
#import "TextFinder.h"
#import "CMRThreadView.h"
#import "CMRHistoryManager.h"

#import "CMXPopUpWindowManager.h"
#import "CMRAttributedMessageComposer.h"

#import <OgreKit/OgreKit.h>

// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"

#pragma mark -

@interface NSLayoutManager(CMRThreadExtensions)
- (BOOL) setTemporaryAttributes : (NSDictionary *) attrs
				 forMatchString : (NSString     *) aString
				   searchOption : (CMRSearchMask ) searchOption;
@end

@implementation NSLayoutManager(CMRThreadExtensions)
- (BOOL) setTemporaryAttributes : (NSDictionary *) attrs
				 forMatchString : (NSString     *) aString
				   searchOption : (CMRSearchMask ) searchOption
{
	NSTextStorage	*textStorage_;
	NSRange			searchRange_;
	NSRange			found;
	NSString		*source_;
	unsigned		options_  = NSLiteralSearch;
	unsigned		targetLength;
	BOOL			ret = NO;
	
	if (searchOption | CMRSearchOptionCaseInsensitive)
		options_ |= NSCaseInsensitiveSearch;

	textStorage_ = [self textStorage];
	searchRange_ = [textStorage_ range];
	targetLength = [textStorage_ length];
	source_ = [textStorage_ string];
	
	while(1) {		
		found = [source_ rangeOfString : aString
							   options : options_
								 range : searchRange_];

		if (0 == found.length) break;
		[self setTemporaryAttributes : attrs forCharacterRange : found];
		ret = YES;

		searchRange_.location = NSMaxRange(found);
		searchRange_.length = targetLength - searchRange_.location;
		if (0 == searchRange_.length) break;
	}
	return ret;
}
@end

#pragma mark -

@implementation CMRThreadViewer(TextViewSupport)
- (NSRange) rangeOfStorageLinkOnly : (NSString *) subString 
						   options : (unsigned  ) mask
							 range : (NSRange   ) aRange
{
	NSAttributedString	*attrs_;
	NSRange				linkRange_;
	id					link_;
	unsigned			charIndex_;
	unsigned			toIndex_;
	NSArray				*filter_;
	
	attrs_ = [[self textView] textStorage];
	UTILAssertRespondsTo(self, @selector(HTMLViewFilteringLinkSchemes:));
	filter_ = [self HTMLViewFilteringLinkSchemes : (CMRThreadView *)[self textView]];
	
	if (mask & NSBackwardsSearch) {
		charIndex_ = NSMaxRange(aRange);
		if (charIndex_ == 0) return kNFRange;
		charIndex_--;
		toIndex_ = 0;
	} else {
		charIndex_ = aRange.location;
		toIndex_ = NSMaxRange(aRange);
	}
	while (1) {
		if (mask & NSBackwardsSearch) {
			if (charIndex_ < toIndex_) break;
		} else {
			if (charIndex_ >= toIndex_) break;
		}
		
		link_ = [attrs_ attribute : NSLinkAttributeName
						  atIndex : charIndex_
			longestEffectiveRange : &linkRange_
						  inRange : aRange];
		
		if (link_ != nil) {
			NSString		*linkstr_;
			NSRange			found_;
			NSURL			*url_;
			
			
			url_ = [NSURL URLWithLink : link_];
			if ([url_ scheme] != nil && NO == [filter_ containsObject : [url_ scheme]]) {
				// メール欄は[url_ scheme]がnil
				linkstr_ = [url_ absoluteString]; 
				
				if (0 == [subString length]) return linkRange_;
				
				found_ = [linkstr_ rangeOfString : subString 
										 options : mask
										   range : NSMakeRange(0, [linkstr_ length])];

				if (found_.location != NSNotFound && found_.length != 0) {
					return linkRange_;
				}
			}
		}
		if (mask & NSBackwardsSearch) {
			if (0 == linkRange_.location) return kNFRange;
			charIndex_ = linkRange_.location -1;
		} else {
			charIndex_ = NSMaxRange(linkRange_);
		}
	}
	
	return kNFRange;
}

- (BOOL) validateAsRegularExpression: (NSString *) aString
{
	BOOL isValid = [OGRegularExpression isValidExpressionString: aString];
	if (isValid) return YES;

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle: NSWarningAlertStyle];
	[alert setMessageText: [NSString stringWithFormat: NSLocalizedString(@"InvalidRegularExpressionMsg", @""), aString]];
	[alert setInformativeText: NSLocalizedString(@"InvalidRegularExpressionInfo", @"")];
	[alert addButtonWithTitle: NSLocalizedString(@"InvalidRegularExpressionOK", @"")];

	NSBeep();
	[alert runModal];
	return NO;
}

- (void) findText : (NSString		*) aString
	 searchOption : (CMRSearchMask   ) searchOption
		  options : (unsigned int	 ) options
			range : (NSRange		 ) aRange
{
	NSString	*text_;
	NSRange		result_;

	UTILNotifyName(BSThreadViewerWillStartFindingNotification);

	text_ = [[self textView] string];

	UTILRequireCondition((text_ && [text_ length]), ErrNotFound);
	UTILRequireCondition((aString && [aString length]), ErrNotFound);
	
	if (CMRSearchOptionLinkOnly & searchOption) {
		result_ = [self rangeOfStorageLinkOnly : aString 
									   options : options
										 range : aRange];
	} else if (CMRSearchOptionUseRegularExpression & searchOption) {
		if (NO == [self validateAsRegularExpression: aString]) return;
		unsigned ogreOption = OgreNoneOption;
		if (options & NSCaseInsensitiveSearch) ogreOption = OgreIgnoreCaseOption;
		result_ = [text_ rangeOfRegularExpressionString: aString options: ogreOption range: aRange];
	} else {
		result_ = [text_ rangeOfString : aString 
							   options : options
								 range : aRange];
	}

	UTILRequireCondition(
		result_.location != NSNotFound && result_.length != 0,
		ErrNotFound);

	[[self textView] setSelectedRange : result_];
	[[self textView] scrollRangeToVisible : result_];

	UTILNotifyInfo3(
		BSThreadViewerDidEndFindingNotification,
		[NSNumber numberWithUnsignedInt : 1],
		kAppThreadViewerFindInfoKey);


	return;

ErrNotFound:
	NSBeep();
	UTILNotifyInfo3(
		BSThreadViewerDidEndFindingNotification,
		[NSNumber numberWithUnsignedInt : 0],
		kAppThreadViewerFindInfoKey);
	return;
}

- (void) findWithOperation : (CMRSearchOptions *) searchOptions_
					 range : (NSRange		    ) aRange
{
	NSString			*search_;
	id					userInfo_;
	CMRSearchMask		option_;
	
	UTILRequireCondition(searchOptions_, ErrNotFound);
	
	search_ = [searchOptions_ findObject];
	userInfo_ = [searchOptions_ userInfo];
	UTILRequireCondition(
		userInfo_ && [userInfo_ respondsToSelector : @selector(unsignedIntValue)], 
		ErrNotFound);
	
	option_ = [userInfo_ unsignedIntValue];
	if (NSBackwardsSearch & [searchOptions_ findOption])
		option_ = (option_ | CMRSearchOptionBackwards);
	
	[self findText : search_
	  searchOption : option_
		   options : [searchOptions_ findOption]
			 range : aRange];
	
ErrNotFound:
	return;
}

#pragma mark IBActions
- (IBAction) findNextText : (id) sender
{
	CMRSearchOptions	*findOperation_;
	NSRange				searchRange_;

	findOperation_ = [[TextFinder standardTextFinder] currentOperation];
	UTILRequireCondition(findOperation_, ErrNotFound);

	searchRange_ = [[self textView] selectedRange];

	if (searchRange_.length == 0) {
		// テキストが選択されていない場合は、ウインドウで「見えている」テキストの先頭から検索を開始する。
		searchRange_ = [[self textView] characterRangeForDocumentVisibleRect];
		searchRange_.length = [[[self textView] string] length] - searchRange_.location;
	} else {
		searchRange_.location = NSMaxRange(searchRange_);
		searchRange_.length = [[[self textView] string] length] - searchRange_.location;
	}
	[self findWithOperation : findOperation_ range : searchRange_];
	
ErrNotFound:
	return;
}

- (IBAction) findPreviousText : (id) sender
{
	CMRSearchOptions	*findOperation_;
	NSRange				searchRange_;
	
	findOperation_ = [[TextFinder standardTextFinder] currentOperation];
	UTILRequireCondition(findOperation_, ErrNotFound);
	
	[findOperation_ setOptionState : YES option : NSBackwardsSearch];
	
	searchRange_ = [[self textView] selectedRange];
	if (searchRange_.length == 0) {
		searchRange_ = [[self textView] characterRangeForDocumentVisibleRect];
		searchRange_.length = NSMaxRange(searchRange_);
		searchRange_.location = 0;
	} else {
		searchRange_.length = searchRange_.location;
		searchRange_.location = 0;
	}
	[self findWithOperation : findOperation_ range : searchRange_];
	
ErrNotFound:
	return;
}

- (BOOL) setUpTemporaryAttributesMatchingString : (NSString *) aString
								   searchOption : (CMRSearchMask    ) searchOption
								inLayoutManager : (NSLayoutManager *) layoutManager
{
	NSDictionary		*dict;
	
#if UTIL_DEBUGGING
	UTILDescBoolean(searchOption & CMRSearchOptionCaseInsensitive);
	UTILDescBoolean(searchOption & CMRSearchOptionZenHankakuInsensitive);
	UTILDescBoolean(searchOption & CMRSearchOptionLinkOnly);
#endif
	
	dict = [NSDictionary dictionaryWithObjectsAndKeys:
				[CMRPref textEnhancedColor],
				NSBackgroundColorAttributeName,
				nil];
	return [layoutManager setTemporaryAttributes : dict
								  forMatchString : aString
									searchOption : searchOption];
}

- (IBAction) findAllByFilter : (id) sender
{
	CMRSearchOptions		*findOperation_;
	
	findOperation_ = [[TextFinder standardTextFinder] currentOperation];
	if (nil == findOperation_)
		return;
	
	[self findTextByFilter : [findOperation_ findObject]
				 targetKey : nil
			  searchOption : [[findOperation_ userInfo] unsignedIntValue]
			  locationHint : [self locationForInformationPopUp]
					hilite : YES];
}

- (IBAction) findAll : (id) sender
{
	CMRSearchOptions	*findOperation_;
	NSLayoutManager		*lM_ = [[self textView] layoutManager];
	BOOL				found;
	TextFinder			*finder_ = [TextFinder standardTextFinder];
	unsigned			k = 1;
	
	findOperation_ = [finder_ currentOperation];
	if (nil == findOperation_)
		return;

	UTILNotifyName(BSThreadViewerWillStartFindingNotification);

	[lM_ removeTemporaryAttribute : NSBackgroundColorAttributeName
				forCharacterRange : [[[self textView] textStorage] range]];
	
	found = [self setUpTemporaryAttributesMatchingString : [findOperation_ findObject]
											searchOption : [[findOperation_ userInfo] unsignedIntValue]
										 inLayoutManager : lM_];

	if (NO == found) {
		NSBeep();
		k = 0;
	}

	UTILNotifyInfo3(
		BSThreadViewerDidEndFindingNotification,
		[NSNumber numberWithUnsignedInt : k],
		kAppThreadViewerFindInfoKey);
}

// available in TestaRossa and later.
- (NSRange) threadMessage : (CMRThreadMessage *) aMessage
			  valueForKey : (NSString		  *) key
			rangeOfString : (NSString         *) aString
				  options : (unsigned          ) options
{
	NSRange		found;
	NSString	*target;
	
	if (nil == aMessage || 0 == [aString length])
		return kNFRange;
	if (nil == key || 0 == [key length])
		return kNFRange;

	target = [aMessage valueForKey : key];
	if (nil == target || 0 == [target length])
		return kNFRange;

	found = [target rangeOfString : aString
						  options : options
							range : [target range]];
	if (found.length != 0) 
		return found;
	
	return kNFRange;
}

//- (NSRange) threadMessage : (CMRThreadMessage *) aMessage
//			rangeOfString : (NSString         *) aString
//				  options : (unsigned          ) options
- (NSRange) threadMessage: (CMRThreadMessage *) aMessage
			rangeOfString: (NSString         *) aString
		regularExpression: (BOOL) isRegExp
				  options: (unsigned          ) options

{
	NSString	*getKeys[] = {
				@"name",
				@"mail",
				@"IDString",
				@"host",
				@"cachedMessage"};
				
	NSRange		found;
	NSString	*target;
	int			i, cnt;

	NSArray		*targets = [CMRPref contentsSearchTargetArray];
	
	if (nil == aMessage || 0 == [aString length])
		return kNFRange;

	cnt = UTILNumberOfCArray(getKeys);
	
	for (i = 0; i < cnt; i++) {
		if ([[targets objectAtIndex: i] intValue] == NSOnState) {
			target = [aMessage valueForKey : getKeys[i]];
			if (nil == target || 0 == [target length])
				continue;

			if (isRegExp) {
				unsigned ogreOption = OgreNoneOption;
				if (options & NSCaseInsensitiveSearch) ogreOption = OgreIgnoreCaseOption;
				found = [target rangeOfRegularExpressionString: aString options: ogreOption range: [target range]];
			} else {
				found = [target rangeOfString : aString
									  options : options
										range : [target range]];
			}
			if (found.length != 0) 
				return found;
		}
	}
	
	return kNFRange;
}

- (void) findTextByFilter : (NSString    *) aString
				targetKey : (NSString	 *) targetKey
			 searchOption : (CMRSearchMask) searchOption
			 locationHint : (NSPoint	  ) location
				   hilite : (BOOL		  ) hilite
{
	CMRThreadLayout	*L = [self threadLayout];
	unsigned		options_  = NSLiteralSearch;
	CMRThreadMessage	*m;
	NSEnumerator		*mIter_;
	
	NSMutableAttributedString		*textBuffer_;
	CMRAttributedMessageComposer	*composer_;
	CMXPopUpWindowController		*popUp_;
	unsigned						nFound = 0;
	UInt32							attributesMask_ = CMRAnyAttributesMask;

	if ([aString length] == 0) return;

	UTILNotifyName(BSThreadViewerWillStartFindingNotification);
	
	if (searchOption | CMRSearchOptionCaseInsensitive)
		options_ |= NSCaseInsensitiveSearch;

	composer_ = [[CMRAttributedMessageComposer alloc] init];
	textBuffer_ = [[NSMutableAttributedString alloc] init];
	
	attributesMask_ &= ~CMRAsciiArtMask;
	attributesMask_ &= ~CMRBookmarkMask;
	[composer_ setAttributesMask : attributesMask_];
	[composer_ setComposingMask : CMRAnyAttributesMask compose : YES];
	
	[composer_ setContentsStorage : textBuffer_];
	
	mIter_ = [L messageEnumerator];
	if (targetKey == nil) {
		BOOL useRegExp = (searchOption & CMRSearchOptionUseRegularExpression);
		if (useRegExp && NO == [self validateAsRegularExpression: aString]) return;

		while (m = [mIter_ nextObject]) {
			NSRange		found;
			
			found = [self threadMessage : m
						  rangeOfString : aString regularExpression: useRegExp
								options : options_];

			if (0 == found.length) continue;

			nFound++;
			[composer_ composeThreadMessage : m];
		}
	} else {
		while (m = [mIter_ nextObject]) {
			NSRange		found;
			
			found = [self threadMessage : m
							valueForKey : targetKey
						  rangeOfString : aString
								options : options_];

			if (0 == found.length) continue;

			nFound++;
			[composer_ composeThreadMessage : m];
		}
	}

	if (0 == nFound) {
		// 見つからなかった
		NSBeep();
		goto CleanUp;
	}

	popUp_ = [CMRPopUpMgr showPopUpWindowWithContext : textBuffer_
										   forObject : [self threadIdentifier]
											   owner : self
										locationHint : location];

	if (hilite)
		[self setUpTemporaryAttributesMatchingString : aString
										searchOption : searchOption
									 inLayoutManager : [[popUp_ textView] layoutManager]];

CleanUp:
	UTILNotifyInfo3(
		BSThreadViewerDidEndFindingNotification,
		[NSNumber numberWithUnsignedInt : nFound],
		kAppThreadViewerFindInfoKey);

	[composer_ release];
	[textBuffer_ release];
	composer_ = nil;
	textBuffer_ = nil;
}

- (IBAction) findFirstText : (id) sender
{
	CMRSearchOptions	*findOperation_;
	NSRange				searchRange_;
	
	findOperation_ = [[TextFinder standardTextFinder] currentOperation];
	UTILRequireCondition(findOperation_, ErrNotFound);
	searchRange_ = NSMakeRange(0, [[[self textView] string] length]);
	
	[self findWithOperation : findOperation_ range : searchRange_];

ErrNotFound:
	return;
}

- (IBAction) findTextInSelection : (id) sender
{
	NSRange				selectedTextRange;
	NSString			*selection;
	TextFinder			*finder_ = [TextFinder standardTextFinder];
	
	selectedTextRange = [[self textView] selectedRange];
	UTILRequireCondition(selectedTextRange.length != 0, ErrNoSelection);

	selection = [[[self textView] string] substringWithRange : selectedTextRange];

	[finder_ showWindow: sender];
	[finder_ setFindString: selection];
	
ErrNoSelection:
	return;
}
@end
