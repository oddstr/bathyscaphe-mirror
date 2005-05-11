//:NSDictionaryEXTest.m
#import "NSDictionaryEXTest.h"
#import <AppKit/AppKit.h>

static NSMutableDictionary *testDictionary;
static NSString *const test_key = @"test";
@implementation NSDictionaryEXTest
- (void) setUp 
{
	testDictionary = [[NSMutableDictionary alloc] init];
}

- (void) tearDown
{
	[testDictionary release];
}

- (void) test_bool
{
	[testDictionary setBool : YES forKey : @"test"];
	[self assertTrue : [testDictionary boolForKey : @"test"]];
	[self assertTrue : [testDictionary boolForKey : @"hoge"
							         defaultValue : YES]];
}



- (void) test_rect
{
	NSRect r;
	
	r = NSMakeRect(1.0f, 555.5f, 0.2f, 1.0f);
	
	[testDictionary setRect : r forKey : test_key];
	[self assertTrue : NSEqualRects(r, [testDictionary rectForKey : test_key])];
}

- (void) test_float
{
	float f = 1.34f;

	[testDictionary setFloat : f forKey : test_key];
	[self assertFloat : [testDictionary floatForKey : test_key]
			equals : f
			precision : 0];
	[self assertFloat : [testDictionary floatForKey : @"hoge"
									   defaultValue : 5.0f]
			equals : 5.0f
			precision : 0];
}

- (void) test_int
{
	int i = -1;
	[testDictionary setInteger : i forKey : test_key];
	[self assertInt : [testDictionary integerForKey : test_key]
			equals : i];
	[self assertInt : [testDictionary integerForKey : @"hoge"
									 defaultValue : 5]
			equals : 5];
}

- (void) test_uns_int
{
	unsigned int ui = 1;
	[testDictionary setUnsignedInt : ui forKey : test_key];
	[self assertInt : [testDictionary unsignedIntForKey : test_key]
			equals : ui];
	[self assertInt : [testDictionary unsignedIntForKey : @"hoge"
									 defaultValue : 5]
			equals : 5];
}
@end
