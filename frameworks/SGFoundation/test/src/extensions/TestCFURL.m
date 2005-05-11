//:TestCFURL.m
#import "TestCFURL.h"
#import <SGFoundation/NSString-SGExtensions.h>


@implementation TestCFURL
- (void) setUp 
{
	//...
}

- (void) tearDown
{
	//...
}
//////////////////////////////////////////////////////////////////////
//////////////////////// [ テストコード ] ////////////////////////////
//////////////////////////////////////////////////////////////////////
- (void) test_CFURLCreateStringByAddingPercentEscapes
{
	NSString	*filepath_;
	NSString	*contents_;
	NSString	*CFURLEncoded_;
	NSString	*FRWKEncoded_;
	filepath_ = 
		[[self class] pathForTestResourceWithName : @"test_urlencode_sjis.txt"];
	contents_ = [NSString stringWithContentsOfFile : filepath_];
	[self assertNotNil : contents_
				format : @"File Contents of %@", 
						[filepath_ lastPathComponent]];
	
	CFURLEncoded_ = (NSString*)CFURLCreateStringByAddingPercentEscapes (
					CFAllocatorGetDefault(), 
					(CFStringRef)contents_, 
					NULL, 
					NULL, 
					kCFStringEncodingShiftJIS);
	FRWKEncoded_ = [contents_ stringByURLEncodingUsingEncoding : 
							CF2NSEncoding(kCFStringEncodingShiftJIS)];
/*	NSLog(@"\nOriginal String: %@\nEncoded(CFURL) : %@\nEncoded(SG)    : %@",
		contents_,
		CFURLEncoded_,
		FRWKEncoded_);
		
*/
		[CFURLEncoded_ release];
}
@end
