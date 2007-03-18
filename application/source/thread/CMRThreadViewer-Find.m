/** 
  * $Id: CMRThreadViewer-Find.m,v 1.15 2007/03/18 14:53:30 tsawada2 Exp $
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * CMRThreadViewer-Action.m から分割 - 2005-02-16 by tsawada2.
  */
#import "CMRThreadViewer_p.h"

#import "BSSearchOptions.h"
#import "TextFinder.h"
#import "CMRThreadLayout.h"
#import "CMRThreadView.h"
#import "CMXPopUpWindowManager.h"
#import "CMRAttributedMessageComposer.h"
#import <OgreKit/OgreKit.h>
#import "CMRMessageAttributesStyling.h"
// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"

#pragma mark -

@interface NSString(BSOgreAddition)
- (NSRange) rangeOfString: (NSString*) expressionString 
			   searchMask: (CMRSearchMask) options
					range: (NSRange) searchRange;
@end

@implementation NSString(BSOgreAddition)
- (NSRange) rangeOfString: (NSString*) expressionString 
			   searchMask: (CMRSearchMask) options
					range: (NSRange) searchRange
{
	OgreSyntax syntax = OgreSimpleMatchingSyntax;
	if (options & CMRSearchOptionUseRegularExpression)
		syntax = OgreRubySyntax;

	unsigned ogreOption = OgreNoneOption;
	if (options & CMRSearchOptionCaseInsensitive)
		ogreOption = OgreIgnoreCaseOption;

	OGRegularExpression *expression;
	NSArray	*matches;
	
	expression = [OGRegularExpression regularExpressionWithString: expressionString
														  options: ogreOption
														   syntax: syntax
												  escapeCharacter: OgreBackslashCharacter];

	matches = [expression allMatchesInString: self options: ogreOption range: searchRange];

	if (matches == nil) {
		return NSMakeRange(NSNotFound, 0);
	} else {
		OGRegularExpressionMatch *match;
		match = (options & CMRSearchOptionBackwards) ? [matches lastObject] : [matches objectAtIndex: 0];
		return [match rangeOfMatchedString];
	}
}
@end

@interface NSLayoutManager(CMRThreadExtensions)
- (BOOL) setTemporaryAttributes : (NSDictionary *) attrs
					  forString : (NSString     *) aString
					  keysArray : (NSArray *) keysArray
					 searchMask : (CMRSearchMask ) searchOption;
@end

@implementation NSLayoutManager(CMRThreadExtensions)
- (BOOL) setTemporaryAttributes : (NSDictionary *) attrs
					  forString : (NSString     *) aString
					  keysArray : (NSArray *) keysArray
					 searchMask : (CMRSearchMask ) searchOption
{
	NSTextStorage	*textStorage_;
	NSRange			searchRange_;
	NSRange			found;
	id				attributesAtPoint;
	NSString		*source_;
	unsigned		targetLength;
	BOOL			ret = NO;

	textStorage_ = [self textStorage];
	searchRange_ = [textStorage_ range];
	targetLength = [textStorage_ length];
	source_ = [textStorage_ string];

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	while(1) {		
		found = [source_ rangeOfString: aString searchMask: searchOption range: searchRange_];

		if (0 == found.length) break;

		attributesAtPoint = [textStorage_ attribute: BSMessageKeyAttributeName atIndex: found.location effectiveRange: NULL];
		if (attributesAtPoint && [keysArray containsObject: attributesAtPoint]) {
//			NSLog(@"Range %@ is OK. Hiliting...", NSStringFromRange(found));
			[self setTemporaryAttributes : attrs forCharacterRange : found];
			ret = YES;
		}
//		NSLog(@"Range %@ is Damepo. Continue.", NSStringFromRange(found));

		searchRange_.location = NSMaxRange(found);
		searchRange_.length = targetLength - searchRange_.location;
		if (0 == searchRange_.length) break;
	}
	[pool release];
	return ret;
}
@end

#pragma mark -

@implementation CMRThreadViewer(TextViewSupport)
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

#pragma mark Find Prev, Next, AtFirst
- (NSRange) rangeOfStorageLinkOnly: (NSString *) subString 
						searchMask: (CMRSearchMask) mask
							 range: (NSRange) aRange
{
	NSAttributedString	*attrs_;
	NSRange				linkRange_;
	id					link_;
	unsigned			charIndex_;
	unsigned			toIndex_;
	NSArray				*filter_;
	BOOL				backwards_;
	
	attrs_ = [[self textView] textStorage];
	UTILAssertRespondsTo(self, @selector(HTMLViewFilteringLinkSchemes:));
	filter_ = [self HTMLViewFilteringLinkSchemes : (CMRThreadView *)[self textView]];
	backwards_ = (mask & CMRSearchOptionBackwards);
	
	if (backwards_) {
		charIndex_ = NSMaxRange(aRange);
		if (charIndex_ == 0) return kNFRange;
		charIndex_--;
		toIndex_ = 0;
	} else {
		charIndex_ = aRange.location;
		toIndex_ = NSMaxRange(aRange);
	}
	while (1) {
		if (backwards_) {
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
									  searchMask : mask
										   range : NSMakeRange(0, [linkstr_ length])];

				if (found_.location != NSNotFound && found_.length != 0) {
					return linkRange_;
				}
			}
		}
		if (backwards_) {
			if (0 == linkRange_.location) return kNFRange;
			charIndex_ = linkRange_.location -1;
		} else {
			charIndex_ = NSMaxRange(linkRange_);
		}
	}

	return kNFRange;
}

- (void) findText: (NSString *) aString
		keysArray: (NSArray *) keysArray
	   searchMask: (CMRSearchMask) searchOption
			range: (NSRange) aRange
{
	NSTextView	*textView_ = [self textView];
	NSString	*text_ = [textView_ string];
	NSRange		result_ = NSMakeRange(NSNotFound, 0);

	UTILNotifyName(BSThreadViewerWillStartFindingNotification);

	UTILRequireCondition((text_ && [text_ length]), ErrNotFound);
	UTILRequireCondition((aString && [aString length]), ErrNotFound);
	
	if (CMRSearchOptionLinkOnly & searchOption) {
		result_ = [self rangeOfStorageLinkOnly: aString 
									searchMask: searchOption
										 range: aRange];
	} else {
		BOOL useRegExp = (CMRSearchOptionUseRegularExpression & searchOption);
		if (useRegExp && NO == [self validateAsRegularExpression: aString]) goto ErrNotFound;

		unsigned int strLength = [aString length];
        while (aRange.length >= strLength) {
//			NSLog(@"aRange: %@", NSStringFromRange(aRange));
			NSAttributedString *attrText_ = [textView_ textStorage];
			id check;

			result_ = [text_ rangeOfString: aString
								searchMask: searchOption
									 range: aRange];

			if (result_.location == NSNotFound)
				break;

			check = [attrText_ attribute: BSMessageKeyAttributeName atIndex: result_.location effectiveRange: NULL];
			if (check && [keysArray containsObject: check]) {
//				NSLog(@"Range %@ is OK.", NSStringFromRange(result_));
				break;
			}
//			NSLog(@"Range %@ is Damepo.", NSStringFromRange(result_));
			if (searchOption & CMRSearchOptionBackwards) {
				aRange.length = result_.location;
			} else {
				aRange.length = [text_ length] - NSMaxRange(result_);
				aRange.location = NSMaxRange(result_);
			}
		}
	}

	UTILRequireCondition(
		result_.location != NSNotFound && result_.length != 0,
		ErrNotFound);

	[textView_ setSelectedRange : result_];
	[textView_ scrollRangeToVisible : result_];

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

- (void) findWithOperation: (BSSearchOptions *) searchOptions
					 range: (NSRange) aRange
{
	UTILRequireCondition(searchOptions, ErrNotFound);

	[self findText: [searchOptions findObject]
		 keysArray: [searchOptions targetKeysArray]
		searchMask: [searchOptions optionMasks]
			 range: aRange];

ErrNotFound:
	return;
}

- (IBAction) findNextText : (id) sender
{
	BSSearchOptions	*findOperation_;
	NSTextView		*textView_ = [self textView];
	NSRange			searchRange_;

	findOperation_ = [[TextFinder standardTextFinder] currentOperation];
	UTILRequireCondition(findOperation_, ErrNotFound);

	searchRange_ = [textView_ selectedRange];

	if (searchRange_.length == 0) {
		// テキストが選択されていない場合は、ウインドウで「見えている」テキストの先頭から検索を開始する。
		searchRange_ = [textView_ characterRangeForDocumentVisibleRect];
		searchRange_.length = [[textView_ string] length] - searchRange_.location;
	} else {
		searchRange_.location = NSMaxRange(searchRange_);
		searchRange_.length = [[textView_ string] length] - searchRange_.location;
	}
	[self findWithOperation : findOperation_ range : searchRange_];
	
ErrNotFound:
	return;
}

- (IBAction) findPreviousText : (id) sender
{
	BSSearchOptions	*findOperation_;
	NSTextView		*textView_ = [self textView];
	NSRange			searchRange_;
	
	findOperation_ = [[TextFinder standardTextFinder] currentOperation];
	UTILRequireCondition(findOperation_, ErrNotFound);
	
	[findOperation_ setOptionState: YES forOption: CMRSearchOptionBackwards];
	
	searchRange_ = [textView_ selectedRange];
	if (searchRange_.length == 0) {
		searchRange_ = [textView_ characterRangeForDocumentVisibleRect];
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

- (IBAction) findFirstText : (id) sender
{
	BSSearchOptions	*findOperation_;
	NSRange			searchRange_;
	
	findOperation_ = [[TextFinder standardTextFinder] currentOperation];
	UTILRequireCondition(findOperation_, ErrNotFound);
	searchRange_ = NSMakeRange(0, [[[self textView] string] length]);
	
	[self findWithOperation : findOperation_ range : searchRange_];

ErrNotFound:
	return;
}

#pragma mark Extract, Hilite
- (BOOL) hiliteForMatchingString: (NSString *) aString
					   keysArray: (NSArray *) keysArray
					searchOption: (CMRSearchMask) searchOption
				 inLayoutManager: (NSLayoutManager *) layoutManager
{
	NSDictionary		*dict;
	
#if UTIL_DEBUGGING
	UTILDescBoolean(searchOption & CMRSearchOptionCaseInsensitive);
	UTILDescBoolean(searchOption & CMRSearchOptionUseRegularExpression);
	UTILDescBoolean(searchOption & CMRSearchOptionLinkOnly);
#endif
	
	dict = [NSDictionary dictionaryWithObjectsAndKeys:
				[CMRPref textEnhancedColor],
				NSBackgroundColorAttributeName,
				nil];
	return [layoutManager setTemporaryAttributes: dict
									   forString: aString
									   keysArray: keysArray
									  searchMask: searchOption];
}

- (NSRange) threadMessage: (CMRThreadMessage *) aMessage
					 keys: (NSArray *) keysArray
			rangeOfString: (NSString *) aString
			   searchMask: (CMRSearchMask) options
{
	NSRange		found;
	NSString	*target;
	NSEnumerator *iter_ = [keysArray objectEnumerator];
	NSString *eachKey;

	if (nil == aMessage || 0 == [aString length])
		return kNFRange;

	while (eachKey = [iter_ nextObject]) {
		target = [aMessage valueForKey : eachKey];
		if (nil == target || 0 == [target length])
			continue;

		found = [target rangeOfString: aString
						   searchMask: options
								range: [target range]];

		if (found.length != 0) 
			return found;
	}
	
	return kNFRange;
}

- (void) findTextByFilter: (NSString *) aString
			   searchMask: (CMRSearchMask) searchOption
			   targetKeys: (NSArray *) keysArray
			 locationHint: (NSPoint) location
{
	CMRThreadLayout	*L = [self threadLayout];
	CMRThreadMessage	*m;
	NSEnumerator		*mIter_;
	
	NSMutableAttributedString		*textBuffer_;
	CMRAttributedMessageComposer	*composer_;
	CMXPopUpWindowController		*popUp_;
	unsigned						nFound = 0;
	UInt32							attributesMask_ = CMRAnyAttributesMask;

	if ([aString length] == 0) return;

	UTILNotifyName(BSThreadViewerWillStartFindingNotification);

	composer_ = [[CMRAttributedMessageComposer alloc] init];
	textBuffer_ = [[NSMutableAttributedString alloc] init];
	
	attributesMask_ &= ~CMRAsciiArtMask;
	attributesMask_ &= ~CMRBookmarkMask;
	[composer_ setAttributesMask : attributesMask_];
	[composer_ setComposingMask : CMRAnyAttributesMask compose : YES];
	
	[composer_ setContentsStorage : textBuffer_];
	
	mIter_ = [L messageEnumerator];

	BOOL useRegExp = (searchOption & CMRSearchOptionUseRegularExpression);
	if (useRegExp && NO == [self validateAsRegularExpression: aString]) return;

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	while (m = [mIter_ nextObject]) {
		NSRange		found;

		found = [self threadMessage: m keys: keysArray rangeOfString: aString searchMask: searchOption];
		if (0 == found.length) continue;

		nFound++;
		[composer_ composeThreadMessage : m];
	}

	[pool release];

	if (0 == nFound) {
		// 見つからなかった
		NSBeep();
		goto CleanUp;
	}

	popUp_ = [CMRPopUpMgr showPopUpWindowWithContext : textBuffer_
										   forObject : [self threadIdentifier]
											   owner : self
										locationHint : location];

	[self hiliteForMatchingString: aString
						keysArray: keysArray
					 searchOption: searchOption
				  inLayoutManager: [[popUp_ textView] layoutManager]];

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

- (IBAction) findAllByFilter : (id) sender
{
	BSSearchOptions		*findOperation_;
	
	findOperation_ = [[TextFinder standardTextFinder] currentOperation];
	if (nil == findOperation_)
		return;
	
	[self findTextByFilter: [findOperation_ findObject]
				searchMask: [findOperation_ optionMasks]
				targetKeys: [findOperation_ targetKeysArray]
			  locationHint: [self locationForInformationPopUp]];
}

- (IBAction) findAll : (id) sender
{
	BSSearchOptions	*findOperation_;
	NSLayoutManager	*lM_ = [[self textView] layoutManager];
	BOOL			found;
	TextFinder		*finder_ = [TextFinder standardTextFinder];
	unsigned		k = 1;
	
	findOperation_ = [finder_ currentOperation];
	if (nil == findOperation_)
		return;

	UTILNotifyName(BSThreadViewerWillStartFindingNotification);

	[lM_ removeTemporaryAttribute : NSBackgroundColorAttributeName
				forCharacterRange : [[[self textView] textStorage] range]];
	
	found = [self hiliteForMatchingString: [findOperation_ findObject]
								keysArray: [findOperation_ targetKeysArray]
							 searchOption: [findOperation_ optionMasks]
						  inLayoutManager: lM_];

	if (NO == found) {
		NSBeep();
		k = 0;
	}

	UTILNotifyInfo3(
		BSThreadViewerDidEndFindingNotification,
		[NSNumber numberWithUnsignedInt : k],
		kAppThreadViewerFindInfoKey);
}

#pragma mark ID Popup Support
- (void) extractMessagesWithIDString: (NSString *) IDString
					   popUpLocation: (NSPoint) location
{
	CMRThreadLayout		*layout = [self threadLayout];
	CMRThreadMessage	*message;
	NSEnumerator		*iter;
	
	NSMutableAttributedString		*textBuffer_;
	CMRAttributedMessageComposer	*composer_;
	CMXPopUpWindowController		*popUp_;
	unsigned						nFound = 0;
	UInt32							attributesMask_ = CMRAnyAttributesMask;

	if (!IDString || [IDString length] == 0) return;

	composer_ = [[CMRAttributedMessageComposer alloc] init];
	textBuffer_ = [[NSMutableAttributedString alloc] init];
	
	attributesMask_ &= ~CMRAsciiArtMask;
	attributesMask_ &= ~CMRBookmarkMask;

	[composer_ setAttributesMask : attributesMask_];
	[composer_ setComposingMask : CMRAnyAttributesMask compose : YES];	
	[composer_ setContentsStorage : textBuffer_];
	
	iter = [layout messageEnumerator];
	while (message = [iter nextObject]) {
		NSString *IDValue = [message valueForKey: @"IDString"];
		if (!IDValue || [IDValue length] == 0) continue;

		if ([IDValue isEqualToString: IDString]) {
			nFound++;
			[composer_ composeThreadMessage: message];
		}
	}

	if (0 == nFound) {
		NSString *notFoundString = [NSString stringWithFormat: NSLocalizedString(@"Such ID Not Found", @""), IDString];
		NSAttributedString *notFoundAttrStr = [[NSAttributedString alloc] initWithString: notFoundString];
		[textBuffer_ appendAttributedString: notFoundAttrStr];
		[notFoundAttrStr release];
	}

	popUp_ = [CMRPopUpMgr showPopUpWindowWithContext : textBuffer_
										   forObject : [self threadIdentifier]
											   owner : self
										locationHint : location];

	[composer_ release];
	[textBuffer_ release];
	composer_ = nil;
	textBuffer_ = nil;
}

#pragma mark Use Selection to Find
- (IBAction) findTextInSelection : (id) sender
{
	NSRange		selectedTextRange;
	NSString	*selection;
	TextFinder	*finder_ = [TextFinder standardTextFinder];
	
	selectedTextRange = [[self textView] selectedRange];
	UTILRequireCondition(selectedTextRange.length != 0, ErrNoSelection);

	selection = [[[self textView] string] substringWithRange : selectedTextRange];

	[finder_ showWindow: sender];
	[finder_ setFindString: selection];
	
ErrNoSelection:
	return;
}
@end
