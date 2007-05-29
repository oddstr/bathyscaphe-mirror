/**
  * $Id: CMRThreadAttributes.m,v 1.8 2007/05/29 21:40:09 tsawada2 Exp $
  * 
  * CMRThreadAttributes.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadAttributes.h"
#import "CMRBBSSignature.h"
#import "CMRThreadVisibleRange.h"
#import "CMRThreadSignature.h"

#import "CMRDocumentFileManager.h"
#import "BoardManager.h"
#import "AppDefaults.h"
#import "CMRHostHandler.h"
//#import "CMRThreadUserStatus.h"



NSString *const CMRThreadAttributesDidChangeNotification = 
					@"CMRThreadAttributesDidChangeNotification";




@implementation CMRThreadAttributes
- (id) initWithDictionary : (NSDictionary *) info
{
	if (self = [super init]) {
		[self addEntriesFromDictionary : info];
	}
	return self;
}
- (void) dealloc
{
	[_attributes release];
	[super dealloc];
}

- (NSMutableDictionary *) getMutableAttributes
{
	if (nil == _attributes) {
		_attributes = [[NSMutableDictionary alloc] init];
	}
	
	return _attributes;
}
- (NSDictionary *) dictionaryRepresentation
{
	return [self getMutableAttributes];
}

- (void) notifyDidChangeAttributes
{
	[[NSNotificationCenter defaultCenter]
		postNotificationName : CMRThreadAttributesDidChangeNotification
					  object : self
					userInfo : [self getMutableAttributes]];
}
- (void) addEntriesFromDictionary : (NSDictionary *) newAttrs
{
	if (nil == newAttrs || 0 == [newAttrs count])
		return;
	// この羅列は何とかしたい…
	[self willChangeValueForKey: @"threadTitle"];
	[self willChangeValueForKey: @"displaySize"];
	[self willChangeValueForKey: @"displayPath"];
	[self willChangeValueForKey: @"modifiedDate"];
	[self willChangeValueForKey: @"createdDate"];
	[self willChangeValueForKey: @"isAAThread"];
	[self willChangeValueForKey: @"isMarkedThread"];
	[self willChangeValueForKey: @"isDatOchiThread"];
	[[self getMutableAttributes] addEntriesFromDictionary : newAttrs];
	[self didChangeValueForKey: @"isDatOchiThread"];
	[self didChangeValueForKey: @"isMarkedThread"];
	[self didChangeValueForKey: @"isAAThread"];
	[self didChangeValueForKey: @"createdDate"];
	[self didChangeValueForKey: @"modifiedDate"];
	[self didChangeValueForKey: @"displayPath"];
	[self didChangeValueForKey: @"displaySize"];
	[self didChangeValueForKey: @"threadTitle"];
	[self notifyDidChangeAttributes];
}

// Deprecated in TestaRossa and later. use - (NSString *) boardName directly instead.
/*- (CMRBBSSignature *) BBSSignature
{
	return [CMRBBSSignature BBSSignatureWithName : [self boardName]];
}*/
- (CMRThreadSignature *) threadSignature
{
	return [CMRThreadSignature 
				threadSignatureWithIdentifier : [self datIdentifier]
									  BBSName : [self boardName]];
}
- (NSString *) datIdentifier
{
	return [[self class] identifierFromDictionary : [self getMutableAttributes]];
}


/* ログファイルがないため更新が必要 */
- (BOOL) needsToBeUpdatedFromLoadedContents
{
	return (nil == [self threadTitle]) || (0 == [self numberOfLoadedMessages]);
}
- (BOOL) needsToUpdateLogFile
{
	return _changed;
}
- (void) setNeedsToUpdateLogFile : (BOOL) flag
{
	_changed = flag;
}

- (unsigned) numberOfLoadedMessages
{
	return [[self getMutableAttributes] unsignedIntForKey : CMRThreadLastLoadedNumberKey
								   defaultValue : 0];
}
- (void) setNumberOfLoadedMessages : (unsigned) n
{
	[[self getMutableAttributes] setUnsignedInt:n forKey:CMRThreadLastLoadedNumberKey];
}

- (unsigned) numberOfMessages
{
	return [[self getMutableAttributes] unsignedIntForKey : CMRThreadNumberOfMessagesKey
								   defaultValue : 0];
}
- (NSString *) path
{
	return [[self class] pathFromDictionary : [self getMutableAttributes]];
}

- (NSString *) threadTitle
{
	return [[self class] threadTitleFromDictionary : [self getMutableAttributes]];
}

- (NSString *) boardName
{
	return [[self class] boardNameFromDictionary : [self getMutableAttributes]];
}
- (NSString *) bbsIdentifier
{
	return [[[self boardURL] stringValue] lastPathComponent];
}

- (NSURL *) boardURL
{
	return [[self class] boardURLFromDictionary : [self getMutableAttributes]];
}

- (NSURL *) threadURL
{
	return [[self class] threadURLFromDictionary : [self getMutableAttributes]];
}

#pragma mark SB3 Addition
- (NSString *) displaySize
{
	NSString *str_;
	id length_;

	length_ = [[self getMutableAttributes] numberForKey: ThreadPlistLengthKey];

	if (length_) {
		unsigned bytes = [length_ unsignedIntValue];
		unsigned kbytes = bytes / 1024;
		str_ = [NSString stringWithFormat: @"%u KB (%u bytes)", kbytes, bytes];
		return str_;
	}
	return nil;
}

- (NSString *) displayPath
{
	NSString	*path_;
//	SGFileRef	*fileRef_;

	path_ = [[self class] pathFromDictionary: [self getMutableAttributes]];
	if (path_ != nil) {
//		fileRef_ = [SGFileRef fileRefWithPath: path_];
//		return [fileRef_ displayPath];
		return path_;
	}
	return nil;
}

- (NSDate *) createdDate
{
	return [[self class] createdDateFromDictionary: [self getMutableAttributes]];
}

- (NSDate *) modifiedDate
{
	return [[self class] modifiedDateFromDictionary: [self getMutableAttributes]];
}
#pragma mark Addition End

- (NSRect) windowFrame
{	
	if (nil == [self getMutableAttributes])
		return NSZeroRect;
	return [[self getMutableAttributes] rectForKey : CMRThreadWindowFrameKey];
}


- (void) setWindowFrame : (NSRect) newFrame
{
	if (NSEqualRects(NSZeroRect, newFrame)) return;
	
	[[self getMutableAttributes] setRect : newFrame
						forKey : CMRThreadWindowFrameKey];
	[self notifyDidChangeAttributes];
	[self setNeedsToUpdateLogFile : YES];
}

- (unsigned) lastIndex
{
	return [[self getMutableAttributes] unsignedIntForKey : CMRThreadLastReadedIndexKey
								   defaultValue : NSNotFound];
}
- (void) setLastIndex : (unsigned) anIndex
{
	NSMutableDictionary	*mdict_ = [self getMutableAttributes];
	id					v;
	
	v = [mdict_ objectForKey : CMRThreadLastReadedIndexKey];
	[[v retain] autorelease];
	if (v && NO == [v respondsToSelector : @selector(unsignedIntValue)]) {
		[mdict_ removeObjectForKey:CMRThreadLastReadedIndexKey];
		v = nil;
	}
	if (NSNotFound == anIndex) {
		if (nil == v) return;
		[mdict_ removeObjectForKey:CMRThreadLastReadedIndexKey];
	} else {
		if ([v unsignedIntValue] == anIndex) return;
		[mdict_ setUnsignedInt:anIndex forKey:CMRThreadLastReadedIndexKey];
	}
	[self setNeedsToUpdateLogFile : YES];
}

- (CMRThreadVisibleRange *) visibleRange
{
	id							rep_;
	CMRThreadVisibleRange		*range_;
	
	UTILRequireCondition([self getMutableAttributes], not_found_entry);
	
	rep_ = [[self getMutableAttributes] objectForKey : CMRThreadVisibleRangeKey];
	UTILRequireCondition(rep_, not_found_entry);
	range_ = [CMRThreadVisibleRange objectWithPropertyListRepresentation : rep_];
	UTILRequireCondition(range_, not_found_entry);
	
	return range_;
	
	not_found_entry:{
		return [CMRThreadVisibleRange defaultVisibleRange];
	}
}
- (void) setVisibleRange : (CMRThreadVisibleRange *) newRange
{
	NSMutableDictionary	*mdict_ = [self getMutableAttributes];
	id					v;
	
	v = [mdict_ objectForKey : CMRThreadVisibleRangeKey];
	[[v retain] autorelease];
	
	if (nil == newRange) {
		if (nil == v) return;
		[mdict_ removeObjectForKey : CMRThreadVisibleRangeKey];
	} else {
		id		newRep = [newRange propertyListRepresentation];
		
		if ([newRep isEqual : v]) return;
		[mdict_ setObject:newRep forKey:CMRThreadVisibleRangeKey];
	}
	[self notifyDidChangeAttributes];
	[self setNeedsToUpdateLogFile : YES];
}

- (void) writeAttributes : (NSMutableDictionary *) aDictionary;
{
	id			v;
	
	v = [[self getMutableAttributes] objectForKey : CMRThreadWindowFrameKey];
	[aDictionary setNoneNil:v forKey:CMRThreadWindowFrameKey];
	v = [[self getMutableAttributes] objectForKey : CMRThreadVisibleRangeKey];
	[aDictionary setNoneNil:v forKey:CMRThreadVisibleRangeKey];
	v = [[self getMutableAttributes] objectForKey : CMRThreadLastReadedIndexKey];
	[aDictionary setNoneNil:v forKey:CMRThreadLastReadedIndexKey];
	/* CMRThreadUserStatus */
	v = [[self getMutableAttributes] objectForKey : CMRThreadUserStatusKey];
	[aDictionary setNoneNil:v forKey:CMRThreadUserStatusKey];
	
}
@end

@implementation CMRThreadAttributes(UserStatus)
/* working with CMRThreadUserStatus */
- (CMRThreadUserStatus *) userStatus
{
	id					rep_;
	CMRThreadUserStatus	*s;
	
	rep_ = [[self dictionaryRepresentation]
				objectForKey : CMRThreadUserStatusKey];
	s = [CMRThreadUserStatus objectWithPropertyListRepresentation : rep_];
	if (nil == s) {
		s = [CMRThreadUserStatus statusWithUInt32Value : 0];
	}
	return s;
}
- (BOOL) isAAThread
{
	return [[self userStatus] isAAThread];
}
- (void) setIsAAThread: (BOOL) flag
{
	CMRThreadUserStatus	*s = [self userStatus];
	
	UTILAssertNotNil(s);
	if ([s isAAThread] == flag)
		return;
	
	[s setAAThread : flag];
	[[self getMutableAttributes]
					   setObject : [s propertyListRepresentation]
						  forKey : CMRThreadUserStatusKey];
	[self setNeedsToUpdateLogFile : YES];
}
- (void) setAAThread : (BOOL) flag
{
	[self setIsAAThread: flag];
}
#pragma mark Vita Additions
- (BOOL) isDatOchiThread
{
	return [[self userStatus] isDatOchiThread];
}
- (void) setIsDatOchiThread: (BOOL) flag
{
	CMRThreadUserStatus	*s = [self userStatus];
	
	UTILAssertNotNil(s);
	if ([s isDatOchiThread] == flag)
		return;
	
	[s setDatOchiThread : flag];
	[[self getMutableAttributes]
					   setObject : [s propertyListRepresentation]
						  forKey : CMRThreadUserStatusKey];
	[self setNeedsToUpdateLogFile : YES];
}
- (void) setDatOchiThread : (BOOL) flag
{
	[self setIsDatOchiThread: flag];
}
- (BOOL) isMarkedThread
{	return [[self userStatus] isMarkedThread];
}
- (void) setIsMarkedThread: (BOOL) flag
{
	CMRThreadUserStatus	*s = [self userStatus];
	
	UTILAssertNotNil(s);
	if ([s isMarkedThread] == flag)
		return;
	
	[s setMarkedThread : flag];
	[[self getMutableAttributes]
					   setObject : [s propertyListRepresentation]
						  forKey : CMRThreadUserStatusKey];
	[self setNeedsToUpdateLogFile : YES];
}
- (void) setMarkedThread : (BOOL) flag
{
	[self setIsMarkedThread: flag];
}
@end
