/**
  * $Id: CMRBBSSignature.m,v 1.1 2005/05/11 17:51:06 tsawada2 Exp $
  * 
  * CMRBBSSignature.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRBBSSignature.h"

#import "CMRDocumentFileManager.h"
#import "CocoMonar_Prefix.h"
#import "missing.h"



@implementation CMRBBSSignature
- (void) setName : (NSString *) aName
{
	id tmp;
	
	UTILAssertNotNil(aName);
	tmp = _name;
	_name = [aName retain];
	[tmp release];
}
+ (id) favoritesListSignature
{
	static CMRBBSSignature *instance_;
	
	if(nil == instance_){
		instance_ = [[self alloc] init];
		[instance_ setName : CMXFavoritesDirectoryName];
	}
	
	return instance_;
}
- (BOOL) isFavorites
{
	return [CMXFavoritesDirectoryName isSameAsString : [self name]];
}

+ (id) BBSSignatureWithName : (NSString   *) bbsName
{
	if([CMXFavoritesDirectoryName isSameAsString : bbsName]){
		return [self favoritesListSignature];
	}
	return [[[self alloc] initWithName : bbsName] autorelease];
}
- (id) initWithName : (NSString   *) bbsName
{
	UTILAssertNotNilArgument(bbsName, @"Board name");
	if([CMXFavoritesDirectoryName isSameAsString : bbsName]){
		[self autorelease];
		return [[self class] favoritesListSignature];
	}
	
	if(self = [self init]){
		[self setName : bbsName];
	}
	return self;
}

- (void) dealloc
{
	[_name release];
	[super dealloc];
}

// CMRPropertyListCoding
+ (id) objectWithPropertyListRepresentation : (id) rep
{
	if(NO == [rep isKindOfClass : [NSString class]])
		return nil;
	
	return [[self class] BBSSignatureWithName : rep];
}
- (id) propertyListRepresentation
{
	return [self name];
}

// NSObject
- (unsigned) hash
{
	return [[self name] hash];
}

- (BOOL) isEqual : (id) other
{
	if(nil == other) return NO;
	if(nil == self) return YES;
	if([super isEqual : other]) return YES;
	
	if([other isKindOfClass : [self class]]){
		CMRBBSSignature	*other_ = other;
		id				obj1, obj2;
		BOOL			result = NO;
		
		obj1 = [self name];
		obj2 = [other_ name];
		result = (obj1 == obj2) ? YES : [obj1 isSameAsString : obj2];
		
		return result;
	}
	
	return NO;
}

- (NSString *) description
{
	return [NSString stringWithFormat : @"%@<name = %@",
					NSStringFromClass([self class]),
					[self name]];
}

// CMRHistoryObject
// 履歴の重複チェック
- (BOOL) isHistoryEqual : (id) anObject
{
	return [self isEqual : anObject];
}

// NSCopying
- (id) copyWithZone : (NSZone *) zone
{
	return [self retain];
}



- (NSString *) name
{
	return _name;
}
- (NSString *) dataRootDirectoryPath
{
	return [[CMRDocumentFileManager defaultManager] directoryWithBoardName : [self name]];
}
- (NSString *) localSubjectTextPath
{
	return [[self dataRootDirectoryPath]
				stringByAppendingPathComponent : CMRAppSubjectTextFileName];
}
- (NSString *) threadsListPlistPath
{
	return [[self dataRootDirectoryPath]
				stringByAppendingPathComponent : [self threadsListPlistFileName]];
}
- (NSString *) threadsListPlistFileName
{
	return CMRThreadsListPlistFileName;
}
@end

