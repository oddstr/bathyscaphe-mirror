//:NSURLTest.m
#import "NSURLTest.h"
#import "NSURL-SGExtensions.h"

#define		URL_STRING		@"http://www.hoge.co.jp/hoge"
@implementation NSURLTest
- (void) setUp 
{
	m_URL = [[NSURL alloc] initWithString : @"http://www.hoge.co.jp/hoge/"];
}

- (void) tearDown
{
	[m_URL release];
	m_URL = nil;
}

- (void) testURLByAppendingPathComponent
{
	NSString	*pathComponent = @"foo";
	NSString	*appendedString_;
	NSURL		*appendedURL_;
	NSURL		*theURL_;
	
	appendedString_ = [NSString stringWithFormat : @"%@/%@/",
						URL_STRING,
						pathComponent];
	appendedURL_ = [NSURL URLWithString : appendedString_];
	[self assertNotNil : appendedURL_
			   message : @"F:Valid URL initialize."];
	[self assert : [m_URL URLByAppendingPathComponent : pathComponent]
		  equals : appendedURL_
		 message : @"appending path component"];


	appendedString_ = [NSString stringWithFormat : @"%@/",
						URL_STRING];
	appendedURL_ = [NSURL URLWithString : appendedString_];
	[self assert : [m_URL URLByAppendingPathComponent : @""]
		  equals : appendedURL_
		 message : @"appending empty path component"];
		



	
	theURL_ = [NSURL URLWithString : @"http://www.hoge.org/"];
	[self assert : [theURL_ URLByAppendingPathComponent : @"hoge"]
		  equals : [NSURL URLWithString : @"http://www.hoge.org/hoge/"]
		 message : @"http://www.hoge.org/"];

	theURL_ = [NSURL URLWithString : @"http://www.hoge.org"];
	[self assert : [theURL_ URLByAppendingPathComponent : @"hoge"]
		  equals : [NSURL URLWithString : @"http://www.hoge.org/hoge/"]
		 message : @"http://www.hoge.org"];
}

- (void) testURLByDeletingLastPathComponent
{
	NSString	*pathComponent = @"foo";
	NSString	*appendedString_;
	NSURL		*appendedURL_;
	
	appendedString_ = [NSString stringWithFormat : @"%@/%@",
						URL_STRING,
						pathComponent];
	
	appendedURL_ = [NSURL URLWithString : appendedString_];
	[self assert : [appendedURL_ URLByDeletingLastPathComponent]
		  equals : m_URL
		 message : @"deleting path component"];

	
	appendedURL_ = [NSURL URLWithString : @"http://kaba.2ch.net/accuse/"];
	[self assert : [appendedURL_ URLByDeletingLastPathComponent]
		  equals : [NSURL URLWithString : @"http://kaba.2ch.net/"]
		 message : @"deleting path component"];
}
@end
