//: CMXThreadDATConvertingTask.m
/**
  * $Id: CMXThreadDATConvertingTask.m,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMXThreadDATConvertingTask.h"
#import "CMRThreadSource.h"
#import "CMXTextParser.h"


@implementation CMXThreadDATConvertingTask
+ (id) taskWithContents : (NSString *) datContents
{
	return [[[self alloc] initWithContents : datContents] autorelease];
}
- (id) initWithContents : (NSString *) datContents
{
	if(self = [super init]){
		[self setContents : datContents];
	}
	return self;
}

- (NSString *) contents
{
	return _contents;
}
- (void) setContents : (NSString *) aContents
{
	id		tmp;
	
	tmp = _contents;
	_contents = [aContents retain];
	[tmp release];
}
- (unsigned) baseIndex
{
	return _baseIndex;
}
- (void) setBaseIndex : (unsigned) aBaseIndex
{
	_baseIndex = aBaseIndex;
}

- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	NSArray				*messageArray_;
	CMRThreadSource		*source_;
	NSString			*title_ = nil;
	
	messageArray_ = [CMXTextParser messageArrayWithDATContents : [self contents]
						baseIndex : [self baseIndex]
						    title : &title_];
	
	if(nil == messageArray_) return;
	if(title_ != nil){
		[self setMessageTitle : title_];
		[CMXMainMessenger 
			postNotificationName :		
				CMRThreadComposingTaskDidLoadAttributesNotification
					object : self
				  userInfo : 
					[NSDictionary dictionaryWithObjectsAndKeys :
						title_, CMRThreadTitleKey, nil]];
	}
	
	source_ = [[CMRThreadSource alloc] initWithThreadAttributes : nil];
	[source_ replaceMessages : messageArray_];
	[CMXMainMessenger postNotificationName : 
				CMRThreadComposingDidFinishNotification
				object : self
				userInfo : 
					[NSDictionary dictionaryWithObjectsAndKeys : 
						source_, kCMRUserInfoSourceKey, nil]];
	
	[source_ release];
	return;
}
@end
