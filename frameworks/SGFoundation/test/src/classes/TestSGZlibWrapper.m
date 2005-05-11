//: TestSGZlibWrapper.m
/**
  * $Id: TestSGZlibWrapper.m,v 1.1.1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * @see SGZlibWrapper.h
  *
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "TestSGZlibWrapper.h"


// Resources...
#define EMPTY_FILENAME	@"Empty"
#define FOO_FILENAME	@"GZIP.rtf"


@implementation TestSGZlibWrapper
- (void) setUp
{
	;
}
- (void) tearDown
{
	;
}


- (NSData *) dataWithFilename : (NSString *) filename
{
	NSString	*path_;
	NSData		*data_;
	
	path_ = [[self class] pathForTestResourceWithName : filename];
	[self assertNotNil:path_ format:@"Path for File(%@) Resource", filename];
	
	data_ = [NSData dataWithContentsOfFile : path_];
	[self assertNotNil:data_ format:@"Contents of File(%@)", path_];
	
	return data_;
}
- (NSData *) gzipDataWithFilename : (NSString *) filename
{
	return [self dataWithFilename : [filename stringByAppendingPathExtension : @"gz"]];
}

- (void) checkGZipFileWithName : (NSString *) filename
					   comment : (NSString *) comment
{
	NSData			*data_;
	NSData			*decompress_;
	NSData			*expected_;
	
	data_ = [self gzipDataWithFilename : filename];
	decompress_ = SGUtilUngzip(data_);
	[self assertNotNil:decompress_ format:@"unzip: %@", comment];
	
	expected_ = [self dataWithFilename : filename];
	[self assert:decompress_ equals:expected_ format:@"decompress: %@", comment];
}

- (void) testEmptyFile
{
	[self checkGZipFileWithName:EMPTY_FILENAME comment:EMPTY_FILENAME];
}
- (void) testStdFile
{
	[self checkGZipFileWithName:FOO_FILENAME comment:FOO_FILENAME];
}
- (void) testNotGZipFile
{
	NSData			*data_;
	NSData			*decompress_;
	
	data_ = [self dataWithFilename : EMPTY_FILENAME];
	decompress_ = SGUtilUngzip(data_);
	[self assertNil:decompress_ name:@"unzip not GZIP data."];
}
@end
