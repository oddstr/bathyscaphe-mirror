//: CMRResourceFileReader.m
/**
  * $Id: CMRResourceFileReader.m,v 1.1.1.1 2005/05/11 17:51:19 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRResourceFileReader.h"
#import "UTILKit.h"


//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
NSString *const CMRReaderUnsupportedFormatException = @"CMRReaderUnsupportedFormatException";



@implementation CMRResourceFileReader
+ (id) readerWithContentsOfFile : (NSString *) filePath
{
	return [[[self alloc] initWithContentsOfFile : filePath] autorelease];
}
+ (id) readerWithContents : (id) fileContents;
{
	return [[[self alloc] initWithContents : fileContents] autorelease];
}
- (id) initWithContentsOfFile : (NSString *) filePath
{
	id			fileContents_;
	Class		cResource_;
	
	cResource_ = [[self class] resourceClass];
	NSAssert2([cResource_ instancesRespondToSelector : 
					@selector(initWithContentsOfFile:)],
				@"instance of %@ must be responseTo <%@>.",
				NSStringFromClass(cResource_),
				NSStringFromSelector(@selector(initWithContentsOfFile:)));
	
	_filepath = [filePath copy];
	fileContents_ = [[cResource_ alloc] initWithContentsOfFile : filePath];
	if(self = [self initWithContents : fileContents_]){
		//...
	}
	[fileContents_ release];
	return self;
}

- (id) initWithContents : (id) fileContents
{
	if(self = [self init]){
NS_DURING
		// サブクラスはここで例外CMRReaderUnsupportedFormatException
		// を投げることもできる。
		// もし、例外が発生せず、かつnil == fileContentsならば、自身を解放し
		// nilを返す。
		[self setFileContents : fileContents];
		
NS_HANDLER
		UTILCatchException(CMRReaderUnsupportedFormatException){
			fileContents = nil;
		}else{
			[localException raise];
		}
		
NS_ENDHANDLER
		
		if(nil == fileContents){
			[self release];
			return nil;
		}
	}
	return self;
}

- (void) dealloc
{
	[_contents release];
	[_filepath release];
	[super dealloc];
}

+ (Class) resourceClass
{
	return [NSString class];
}
- (id) fileContents
{
	return _contents;
}
- (void) setFileContents : (id) aFileContents
{
	id tmp;
	
	if(aFileContents != nil){
		if(NO == [aFileContents isKindOfClass : [[self class] resourceClass]]){
			[NSException raise : CMRReaderUnsupportedFormatException
						format : @"Unsupported file contents. "
								 @"expected %@ but was %@",
								 NSStringFromClass([[self class] resourceClass]),
								 NSStringFromClass([aFileContents class])];
		}
	}
	
	tmp = _contents;
	_contents = [aFileContents retain];
	[tmp release];
}
- (NSString *) filepath
{
	return _filepath;
}
@end
