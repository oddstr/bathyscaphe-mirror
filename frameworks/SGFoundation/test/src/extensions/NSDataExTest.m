//:NSDataExTest.m
#import "NSDataExTest.h"
#import "NSData-SGExtensions.h"
#import "SGFileRef.h"



#define TEST_URLENCODE_SJIS_TXT		@"test_urlencode_sjis.txt"
@implementation NSDataExTest
- (NSString *) sampleFilepath
{
	return [[self class] pathForTestResourceWithName : TEST_URLENCODE_SJIS_TXT];
}
- (void) setUp 
{
	//...
}

- (void) tearDown
{
	//...
}

- (void) test_dataWithContentsOfFileReference
{
	SGFileRef		*fileRef_;
	NSString			*filepath_;
	NSData				*filedata_;
	
	filepath_ = [self sampleFilepath];
	[self assertNotNil : filepath_
			   message : @"F:sampleFilepath"];
	fileRef_ = [SGFileRef fileRefWithPath : filepath_];
	[self assertNotNil : fileRef_
			   message : @"F:fileRefWithPath"];
	
	filedata_ = [NSData dataWithContentsOfFileRef : fileRef_];
	[self assert : filedata_
			equals : [NSData dataWithContentsOfFile : filepath_]
			message : @"F:dataWithContentsOfFileReference"];
}
@end
