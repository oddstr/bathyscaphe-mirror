/**
  * $Id: CMRThreadLinkProcessor.m,v 1.6 2007/11/20 04:21:35 tsawada2 Exp $
  * 
  * CMRThreadLinkProcessor.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadLinkProcessor.h"

#import "CMRMessageAttributesStyling.h"
#import "BoardManager.h"
#import "CMRDocumentFileManager.h"
#import "CMRHostHandler.h"


// for debugging only
#define UTIL_DEBUGGING				0
#import "UTILDebugging.h"




/* 全角数字 --> 半角数字 */
static NSString *decimalDigitStringJpanese2Ascii(NSString *str);
static void scanResLinkElement_(NSString *str, NSMutableIndexSet *buffer);



@implementation CMRThreadLinkProcessor
+ (BOOL) parseBoardLink: (id) aLink boardName: (NSString **) pBoardName boardURL: (NSURL **) pBoardURL
{
	NSURL			*link_;

	NSString	*boardName_ = nil;
	
	BOOL		result_ = NO;
	
	
	link_ = [NSURL URLWithLink : aLink];
	UTILRequireCondition(link_, ReturnResult);

	// 最低限の救済措置として、末尾に「index.html」などがくっついていた場合は除去を試みる
	{
		CFStringRef lastPathExt = CFURLCopyPathExtension((CFURLRef)link_);
		if (lastPathExt != NULL) {
			CFURLRef	anotherLink_ = CFURLCreateCopyDeletingLastPathComponent(kCFAllocatorDefault, (CFURLRef)link_);
			link_ = [[(NSURL *)anotherLink_ copy] autorelease];
			CFRelease(anotherLink_);
			CFRelease(lastPathExt);
		}
	}

	boardName_ = [[BoardManager defaultManager] boardNameForURL : link_];

	UTILRequireCondition(boardName_, ReturnResult);
	result_ = YES;

ReturnResult:
	if (pBoardName != NULL) *pBoardName = boardName_;
	if (pBoardURL  != NULL) *pBoardURL = link_;
	
	return result_;
}

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

+ (BOOL)isMessageLinkUsingLocalScheme:(id)aLink messageIndexes:(NSIndexSet **)indexSetPtr
{
	NSString			*str_;
	NSArray				*comps_;
	NSEnumerator		*iter_;
	NSString			*elem_;

	NSMutableIndexSet	*buffer_ = [NSMutableIndexSet indexSet];
	
	UTIL_DEBUG_METHOD;
	UTIL_DEBUG_WRITE1(@"aLink = %@", [aLink stringValue]);
	
	UTILRequireCondition(aLink, RetMessageLink);
	
	str_ = [aLink stringValue];
	str_ = [str_ stringByDeletingURLScheme:CMRAttributeInnerLinkScheme];
	comps_ = [str_ componentsSeparatedByCharacterSequenceFromSet:[NSCharacterSet innerLinkSeparaterCharacterSet]];

	UTIL_DEBUG_WRITE1(@"str_ = %@", [str_ stringValue]);
	UTIL_DEBUG_WRITE1(@"comps_ = %@", [comps_ stringValue]);
	
	UTILRequireCondition(comps_ && [comps_ count], RetMessageLink);
	
	iter_ = [comps_ objectEnumerator];
	while (elem_ = [iter_ nextObject]) {
		scanResLinkElement_(elem_, buffer_);
	}

	if ([buffer_ count] > 0) {
		if (indexSetPtr != NULL) *indexSetPtr = buffer_;
		return YES;
	}

RetMessageLink:
	return NO;
}

+ (BOOL) isBeProfileLinkUsingLocalScheme : (id) aLink linkParam : (NSString **) aParam
{
	NSString			*str_ = nil;
	BOOL				ret = NO;

	UTILRequireCondition(aLink, RetMessageLink);
	
	str_ = [aLink stringValue];
	str_ = [str_ stringByDeletingURLScheme : CMRAttributesBeProfileLinkScheme];

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
static void scanResLinkElement_(NSString *str, NSMutableIndexSet *buffer)
{
	if (!str || [str length] == 0) {
		return;
	}

	NSMutableString		*tmp;
	NSMutableIndexSet	*tmpIndexes = [NSMutableIndexSet indexSet];
	
	UTIL_DEBUG_FUNCTION;
	str = decimalDigitStringJpanese2Ascii(str);
	tmp = [NSMutableString stringWithString:str];
	UTIL_DEBUG_WRITE1(@"string: %@", tmp);

	[tmp replaceCharactersInSet:[NSCharacterSet innerLinkRangeCharacterSet] toString:@" "];
	UTIL_DEBUG_WRITE1(@"Replace separater, trim: %@", tmp);
	
	NSScanner	*scan = [NSScanner scannerWithString:tmp];
	int			idx = 0;

	[scan setCharactersToBeSkipped:[NSCharacterSet whitespaceCharacterSet]];
	while (1) {
		if (![scan scanInt:&idx])
			break;
		if (idx < 1) continue;
		
		// 他のメソッドはレス番号を０ベースとして扱うので
		UTIL_DEBUG_WRITE1(@"Index: %i",idx-1);
		[tmpIndexes addIndex:(idx-1)];
	}

	unsigned int numOfIdxes = [tmpIndexes count];

	UTIL_DEBUG_WRITE1(@"tmpIndexes: %@", bar);

	if (numOfIdxes == 0) {
		return;
	} else if (numOfIdxes == 2) {
		unsigned int first = [tmpIndexes firstIndex];
		unsigned int last = [tmpIndexes lastIndex];
		NSRange	foo = NSMakeRange(first, last-first+1);
		[buffer addIndexesInRange:foo];
	} else {
		[buffer addIndexes:tmpIndexes];
	}

	UTIL_DEBUG_WRITE1(@"IndexSet(buffer): %@", buffer);
}
