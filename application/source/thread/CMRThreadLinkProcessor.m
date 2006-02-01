/**
  * $Id: CMRThreadLinkProcessor.m,v 1.3 2006/02/01 17:39:08 tsawada2 Exp $
  * 
  * CMRThreadLinkProcessor.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadLinkProcessor.h"

#import "AppDefaults.h"
#import "BoardManager.h"
#import "CMXTextParser.h"
#import "CMXPopUpWindowManager.h"
#import "CMRDocumentFileManager.h"

//#import "NSCharacterSet+CMXAdditions.h"
#import "CMRHostHandler.h"


// for debugging only
#define UTIL_DEBUGGING				0
#import "UTILDebugging.h"




/* ëSäpêîéö --> îºäpêîéö */
static NSString *decimalDigitStringJpanese2Ascii(NSString *str);
static int scanResLinkElement_(NSString *str, SGBaseRangeArray *buffer);



@implementation CMRThreadLinkProcessor
+ (BOOL) parseThreadLink : (id         ) aLink
               boardName : (NSString **) pBoardName
                boardURL : (NSURL    **) pBoardURL
                filepath : (NSString **) pFilepath
{
	NSURL			*link_;
	CMRHostHandler	*handler_;
	
	NSString	*bbs_;
	NSString	*key_;
	unsigned	stIndex_;
	unsigned	endIndex_;
	BOOL		showFirst_;
	
	NSURL		*boardURL_  = nil;
	NSString	*boardName_ = nil;
	NSString	*filepath_  = nil;
	
	BOOL		result_ = NO;
	
	
	link_ = [NSURL URLWithLink : aLink];
	UTILRequireCondition(link_, ReturnResult);
	handler_ = [CMRHostHandler hostHandlerForURL : link_];
	UTILRequireCondition(handler_, ReturnResult);
	
	if (NO == [handler_ parseParametersWithReadURL:link_
							bbs:&bbs_ key:&key_
							start:&stIndex_ to:&endIndex_
							showFirst:&showFirst_])
		goto ReturnResult;
	
	boardURL_ = [handler_ boardURLWithURL:link_ bbs:bbs_];
	UTILRequireCondition(boardURL_, ReturnResult);
	
	boardName_ = [[BoardManager defaultManager] boardNameForURL : boardURL_];

	UTILRequireCondition(boardName_, ReturnResult);
	filepath_ = [[CMRDocumentFileManager defaultManager] 
				threadPathWithBoardName : boardName_
						  datIdentifier : key_];
	result_ = YES;

ReturnResult:
	if (pBoardName != NULL) *pBoardName = boardName_;
	if (pBoardURL  != NULL) *pBoardURL = boardURL_;
	if (pFilepath  != NULL) *pFilepath = filepath_;
	
	return result_;
}

+ (BOOL) isMessageLinkUsingLocalScheme : (id                ) aLink
							rangeArray : (SGBaseRangeArray *) rangeBuffer
{
	NSString			*str_;
	NSArray				*comps_;
	NSEnumerator		*iter_;
	NSString			*elem_;
	BOOL				ret = NO;
	
	UTIL_DEBUG_METHOD;
	UTIL_DEBUG_WRITE1(@"aLink = %@", [aLink stringValue]);
	
	UTILRequireCondition(aLink, RetMessageLink);
	
	str_ = [aLink stringValue];
	str_ = [str_ stringByDeletingURLScheme : CMRAttributeInnerLinkScheme];
	comps_ = [str_ componentsSeparatedByCharacterSequenceFromSet : 
						[NSCharacterSet innerLinkSeparaterCharacterSet]];
	UTIL_DEBUG_WRITE1(@"str_ = %@", [str_ stringValue]);
	UTIL_DEBUG_WRITE1(@"comps_ = %@", [comps_ stringValue]);
	
	UTILRequireCondition(comps_ && [comps_ count], RetMessageLink);
	
	[rangeBuffer removeAll];
	iter_   = [comps_ objectEnumerator];
	while (elem_ = [iter_ nextObject]) {
		if (scanResLinkElement_(elem_, rangeBuffer) > 0)
			ret = YES;
	}
	
RetMessageLink:
	return ret;
}

+ (BOOL) isBeProfileLinkUsingLocalScheme : (id) aLink linkParam : (NSString **) aParam
{
	NSString			*str_ = nil;
	BOOL				ret = NO;
	
	//NSLog(@"aLink = %@", [aLink stringValue]);
	
	UTILRequireCondition(aLink, RetMessageLink);
	
	str_ = [aLink stringValue];
	str_ = [str_ stringByDeletingURLScheme : CMRAttributesBeProfileLinkScheme];

	//NSLog(@"str_ = %@", [str_ stringValue]);

	if (str_) ret = YES;
	
RetMessageLink:
	if (aParam != NULL) *aParam = str_;
	return ret;
}
@end


static NSString *decimalDigitStringJpanese2Ascii(NSString *str)
{
	NSCharacterSet	*numSet_ = [NSCharacterSet numberCharacterSet_JP];
	unichar			*buffer_ = NULL;
	unsigned		length_  = [str length];
	unsigned		i;
	NSString		*result_ = str;
	
	if (nil == str || 0 == length_)
		return @"";
	
	for (i = 0; i < length_; i++) {
		unichar		c;
		
		c = [str characterAtIndex : i];
		if (NO == [numSet_ characterIsMember : c])
			continue;
		
		if (NULL == buffer_) {
			buffer_ = malloc(sizeof(unichar) * length_);
			if (NULL == buffer_)
				return @"";
			[str getCharacters : buffer_];
		}
		
		buffer_[i] = CMRConvertToNumericCharacter(c);
	}
	
	if (buffer_ != NULL) {
		result_ = [[[NSString alloc] 
						initWithCharactersNoCopy : buffer_
						length : length_
						freeWhenDone : YES] autorelease];
		buffer_ = NULL;
	}
	
	return result_;
}

/*
A - B ==> {A, B-A}
A - B - C ==> {A, 1}, {B, 1}, {C, 1}, 
*/
static int scanResLinkElement_(NSString *str, SGBaseRangeArray *buffer)
{
	NSMutableString		*tmp;
	
	if (nil == str || 0 == [str length])
		return 0;
	
	UTIL_DEBUG_FUNCTION;
	str = decimalDigitStringJpanese2Ascii(str);
	tmp = [NSMutableString stringWithString : str];
	UTIL_DEBUG_WRITE1(@"string: %@", tmp);
	
	[tmp replaceCharactersInSet : [NSCharacterSet innerLinkRangeCharacterSet]
					   toString : @" "];
	UTIL_DEBUG_WRITE1(@"Replace separater, trim: %@", tmp);
	
	NSRange		indexRange = kNFRange;
	NSScanner	*scan = [NSScanner scannerWithString : tmp];
	int			idx = 0;
	int			count = 0;
	
	[scan setCharactersToBeSkipped:[NSCharacterSet whitespaceCharacterSet]];
	while (1) {
		if (NO == [scan scanInt:&idx])
			break;
		if (idx < 1) continue;
		
		// ëºÇÃÉÅÉ\ÉbÉhÇÕÉåÉXî‘çÜÇÇOÉxÅ[ÉXÇ∆ÇµÇƒàµÇ§ÇÃÇ≈
		indexRange.location = idx -1;
		indexRange.length = 1;
		
		UTIL_DEBUG_WRITE1(@"IndexRange: %@", NSStringFromRange(indexRange));
		[buffer append : indexRange];
		count++;
	}
	if (2 == count) {
		idx = indexRange.location;	// 2
		
		[buffer removeLast];
		indexRange = [buffer last];	// 1
		
		if (idx >= indexRange.location) {
			indexRange.length += (idx - indexRange.location);
		} else {
			unsigned tmp_ = indexRange.location;
			// ãtèëÇ´
			indexRange.location = idx;
			indexRange.length += (tmp_ - idx);
		}
		
		[buffer removeLast];
		[buffer append : indexRange];
	}
	
	return count;
}
