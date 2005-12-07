/** 
  * $Id: CMRThreadViewer-Find.m,v 1.6 2005/12/07 13:28:31 tsawada2 Exp $
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
#import "CMRThreadDownloadTask.h"

#import "CMRSearchOptions.h"
#import "TextFinder.h"
#import "CMRThreadView.h"
#import "CMRHistoryManager.h"

#import "CMXPopUpWindowManager.h"
#import "CMRAttributedMessageComposer.h"


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

- (void) findText : (NSString		*) aString
	 searchOption : (CMRSearchMask   ) searchOption
		  options : (unsigned int	 ) options
			range : (NSRange		 ) aRange
{
	NSString	*text_;
	NSRange		result_;
	TextFinder	*finder_ = [TextFinder standardTextFinder];
	
	[[finder_ notFoundField] setHidden : YES];
	text_ = [[self textView] string];

	UTILRequireCondition((text_ && [text_ length]), ErrNotFound);
	UTILRequireCondition((aString && [aString length]), ErrNotFound);
	
	if (CMRSearchOptionLinkOnly & searchOption) {
		result_ = [self rangeOfStorageLinkOnly : aString 
									   options : options
										 range : aRange];
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

	return;

ErrNotFound:
	NSBeep();
	[[finder_ notFoundField] setHidden : NO];
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
	searchRange_.location = NSMaxRange(searchRange_);
	searchRange_.length = [[[self textView] string] length] - searchRange_.location;

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
	searchRange_.length = searchRange_.location;
	searchRange_.location = 0;
	
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
			  searchOption : [[findOperation_ userInfo] unsignedIntValue]//];
			  locationHint : [self locationForInformationPopUp]
			  hiliteResult : YES];
}

- (IBAction) findAll : (id) sender
{
	CMRSearchOptions	*findOperation_;
	NSLayoutManager		*lM_ = [[self textView] layoutManager];
	BOOL				found;
	TextFinder			*finder_ = [TextFinder standardTextFinder];
	
	findOperation_ = [finder_ currentOperation];
	if (nil == findOperation_)
		return;

	[[finder_ notFoundField] setHidden : YES];

	[lM_ removeTemporaryAttribute : NSBackgroundColorAttributeName
				forCharacterRange : [[[self textView] textStorage] range]];
	
	found = [self setUpTemporaryAttributesMatchingString : [findOperation_ findObject]
											searchOption : [[findOperation_ userInfo] unsignedIntValue]
										 inLayoutManager : lM_];

	if (NO == found) {
		NSBeep();
		[[finder_ notFoundField] setHidden : NO];
	}
}

- (NSRange) threadMessage : (CMRThreadMessage *) aMessage
			rangeOfString : (NSString         *) aString
				  options : (unsigned          ) options
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
	
	if (nil == aMessage || 0 == [aString length])
		return kNFRange;

	cnt = UTILNumberOfCArray(getKeys);
	
	for (i = 0; i < cnt; i++) {
		target = [aMessage valueForKey : getKeys[i]];
		if (nil == target || 0 == [target length])
			continue;

		found = [target rangeOfString : aString
							  options : options
								range : [target range]];
		if (found.length != 0) 
			return found;
	}
	
	return kNFRange;
}

- (void) findTextByFilter : (NSString    *) aString
			 searchOption : (CMRSearchMask) searchOption
			 locationHint : (NSPoint	  ) location
			 hiliteResult : (BOOL		  ) hilite
//- (void) findTextByFilter : (NSString    *) aString
//			 searchOption : (CMRSearchMask) searchOption
{
	CMRThreadLayout	*L = [self threadLayout];
	unsigned		options_  = NSLiteralSearch;
	//NSPoint			popUpLocation_;
	
	CMRThreadMessage	*m;
	NSEnumerator		*mIter_;
	
	NSMutableAttributedString		*textBuffer_;
	CMRAttributedMessageComposer	*composer_;
	CMXPopUpWindowController		*popUp_;
	unsigned						nFound = 0;
	UInt32							attributesMask_ = CMRAnyAttributesMask;
	
	//TextFinder	*finder_ = [TextFinder standardTextFinder];

	if ([aString length] == 0) return;

	//[[finder_ notFoundField] setHidden : YES];
	
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
	while (m = [mIter_ nextObject]) {
		NSRange		found;
		
		found = [self threadMessage : m
					  rangeOfString : aString
							options : options_];

		if (0 == found.length) continue;

		nFound++;
		[composer_ composeThreadMessage : m];
	}

	if (0 == nFound) {
		// 見つからなかった
		NSBeep();
		//[[finder_ notFoundField] setHidden : NO];
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
	CMRSearchOptions	*findOperation_;
	NSRange				searchRange_;
	NSString			*selection;
	TextFinder			*finder_ = [TextFinder standardTextFinder];
	
	findOperation_ = [finder_ currentOperation];
	UTILRequireCondition(findOperation_, ErrNotFound);
	searchRange_ = [[self textView] selectedRange];
	UTILRequireCondition(searchRange_.length != 0, ErrNotFound);

	selection = [[[self textView] string] substringWithRange : [[self textView] selectedRange]];
	if (![[finder_ window] isVisible]) {
	    [finder_ showWindow : nil];
	}
	[finder_ setFindString : selection];
	
ErrNotFound:
	return;
}
@end