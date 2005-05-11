//: NSString+JapaneseTest.m
/**
  * $Id: NSString+JapaneseTest.m,v 1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSString+JapaneseTest.h"
#import "UTILKit.h"


#define kNSString_JapaneseTestFile	@"JapaneseStringTest.plist"

#define kStringKey			@"String"
#define kExpectedRangeKey	@"Result"
#define kSubStringKey		@"SubString"
#define kSearchRangeKey		@"Range"
#define kCaseInsensitiveKey	@"CaseInsensitive"
#define kBackwardKey		@"Backward"
#define kAnchoredKey		@"Anchored"

@implementation NSString_JapaneseTest
- (void) setUp
{
	;
}
- (void) tearDown
{
	;
}

- (void) test_main
{
	NSString		*path_;
	NSArray			*allTests_;
	NSEnumerator	*iter_;
	NSDictionary	*item_;
	unsigned		index_ = 0;
	
	// テスト定義ファイルの読み込み
	path_ = [[self class] pathForTestResourceWithName : kNSString_JapaneseTestFile];
	allTests_ = [NSArray arrayWithContentsOfFile : path_];
	UTILAssertNotNil(allTests_);
	
	iter_ = [allTests_ objectEnumerator];
	while(item_ = [iter_ nextObject]){
		id			tmp;
		NSString	*string_;
		NSRange		expectedRange_;
		NSRange		searchRange_;
		NSString	*subString_;
		unsigned	mask_ = 0;
		NSRange		result_;
		
		// 文字列
		string_ = [item_ objectForKey : kStringKey];
		UTILAssertNotNil(string_);
		// 結果
		tmp = [item_ objectForKey : kExpectedRangeKey];
		UTILAssertNotNil(tmp);
		expectedRange_ = NSRangeFromString(tmp);
		// 検索文字
		subString_ = [item_ objectForKey : kSubStringKey];
		// 範囲
		tmp = [item_ objectForKey : kSearchRangeKey];
		searchRange_ = (tmp != nil) ? NSRangeFromString(tmp) : [string_ range];
		// オプション
		if([item_ boolForKey : kBackwardKey])
			mask_ |= NSBackwardsSearch;
		if([item_ boolForKey : kAnchoredKey])
			mask_ |= NSAnchoredSearch;
		if([item_ boolForKey : kCaseInsensitiveKey])
			mask_ |= NSCaseInsensitiveSearch;
		
		mask_ |= SGZenkakuHankakuInsensitiveSearch;
		result_ = [string_ searchRangeOfString:subString_ options:mask_
						range:searchRange_];
		
		[self assertTrue : NSEqualRanges(result_, expectedRange_)
			format : @"Test(%u): expected %@ but was %@.\n"
					 @"src=%@ sub=%@ option=%u range=%@",
						index_,
						NSStringFromRange(expectedRange_),
						NSStringFromRange(result_),
						string_,
						subString_,
						mask_,
						NSStringFromRange(searchRange_)];
		
		index_++;
	}
}

@end
