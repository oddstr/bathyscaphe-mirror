/**
  * $Id: CMRThreadSubjectComposer.m,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadSubjectComposer.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadSubjectComposer.h"
#import "CocoMonar_Prefix.h"
#import "CMRDocumentFileManager.h"



@implementation CMRThreadSubjectComposer
- (void) dealloc
{
	[_boardName release];
	[_subject release];
	[super dealloc];
}

- (NSString *) boardName
{
	return _boardName;
}
- (void) setBoardName : (NSString *) aBoardName
{
	id		tmp;
	
	tmp = _boardName;
	_boardName = [aBoardName retain];
	[tmp release];
}
+ (id) composerWithBoardName : (NSString *) aBoardName;
{
	id		instance_;
	
	instance_ = [[[self alloc] init] autorelease];
	[instance_ setBoardName : aBoardName];
	
	return instance_;
}

- (NSMutableDictionary *) subject
{
	if(nil == _subject)
		_subject = [[NSMutableDictionary alloc] init];
	
	return _subject;
}


- (void) composeIndex : (unsigned int) index
{
	[[self subject] setObject : [NSNumber numberWithUnsignedInt : index]
					   forKey : CMRThreadSubjectIndexKey];
}

- (void) composeIdentifier : (NSString *) anIdentifier
{
	NSString		*filepath_;
	
	if(nil == anIdentifier) return;
	
	[[self subject] setNoneNil : anIdentifier
					    forKey : ThreadPlistIdentifierKey];
	
	filepath_ = [[CMRDocumentFileManager defaultManager] 
					threadPathWithBoardName : [self boardName]
					 	      datIdentifier : anIdentifier];
	[[self subject] setNoneNil : filepath_
					    forKey : CMRThreadLogFilepathKey];
}


- (void) composeTitle : (NSString *) title
{
	[[self subject] setObject : title
					   forKey : CMRThreadTitleKey];
}

- (void) composeCount : (unsigned int) resCount
{
	[[self subject] setObject : [NSNumber numberWithUnsignedInt : resCount]
					   forKey : CMRThreadNumberOfMessagesKey];
}

- (id) getSubject
{
	id		subject_;
	subject_ = [[self subject] mutableCopyWithZone : [self zone]];
	[subject_ setNoneNil : [self boardName]
				  forKey : ThreadPlistBoardNameKey];
	
	[[self subject] removeAllObjects];
	return [subject_ autorelease];
}
@end
