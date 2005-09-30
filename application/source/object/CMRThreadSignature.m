/**
  * $Id: CMRThreadSignature.m,v 1.2 2005/09/30 01:08:32 tsawada2 Exp $
  * 
  * CMRThreadSignature.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadSignature_p.h"
#import "CMRDocumentFileManager.h"


@implementation CMRThreadSignature
//////////////////////////////////////////////////////////////////////
/////////////////////// [ 初期化・後始末 ] ///////////////////////////
//////////////////////////////////////////////////////////////////////
+ (id) threadSignatureFromFilepath : (NSString *) filepath
{
	return [[[self alloc] initFromFilepath : filepath] autorelease];
}
- (id) initFromFilepath : (NSString *) filepath
{
	CMRBBSSignature		*bbsSignature_;
	NSString			*bbsName_;
	NSString			*datIdentifier_;
	
	bbsName_ = [[CMRDocumentFileManager defaultManager] boardNameWithLogPath : filepath];
	bbsSignature_ = [CMRBBSSignature BBSSignatureWithName : bbsName_];
	datIdentifier_ = [[CMRDocumentFileManager defaultManager]
								datIdentifierWithLogPath : filepath];
	return [self initWithIdentifier : datIdentifier_
					   BBSSignature : bbsSignature_];
}

+ (id) threadSignatureWithIdentifier : (NSString        *) anIdentifier
						BBSSignature : (CMRBBSSignature *) bbsSignature
{
	return [[[self alloc]  initWithIdentifier : anIdentifier
								 BBSSignature : bbsSignature] autorelease];
}
- (id) initWithIdentifier : (NSString        *) anIdentifier
			 BBSSignature : (CMRBBSSignature *) bbsSignature
{
	if(nil == anIdentifier || nil == bbsSignature){
		[self release];
		return nil;
	}
	if(self = [self init]){
		[self setIdentifier : anIdentifier];
		[self setBBSSignature : bbsSignature];
	}
	return self;
}

- (void) dealloc
{
	[m_identifier release];
	[m_BBSSignature release];
	[super dealloc];
}
//////////////////////////////////////////////////////////////////////
//////////////////// [ インスタンスメソッド ] ////////////////////////
//////////////////////////////////////////////////////////////////////
// NSObject
- (unsigned) hash
{
	return [[self BBSSignature] hash] ^ [[self identifier] hash];
}
- (BOOL) isEqual : (id) other
{
	if([super isEqual : other]) return YES;
	
	if([other isKindOfClass : [self class]]){
		CMRThreadSignature	*other_ = other;
		id					obj1, obj2;
		BOOL				result = NO;
		
		obj1 = [self identifier];
		obj2 = [other_ identifier];
		result = (obj1 == obj2) ? YES : [obj1 isEqualToString : obj2];
		if(NO == result) return NO;
		
		obj1 = [self BBSSignature];
		obj2 = [other_ BBSSignature];
		result = (obj1 == obj2) ? YES : [obj1 isEqual : obj2];
		
		return result;
	}
	return NO;
}

- (NSString *) description
{
	return [NSString stringWithFormat : @"%@<identifier = %@, BBS = %@>",
					NSStringFromClass([self class]),
					[self identifier],
					[self BBSSignature]];
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
// CMRPropertyListCoding
#define kPropertyListBBSIdentifierKey		@"BBS"
#define kPropertyListDATIdentifierKey		@"DAT"
+ (id) objectWithPropertyListRepresentation : (id) rep
{
	id			bbsSignature_;
	NSString	*identifier_;
	
	if(NO == [rep isKindOfClass : [NSDictionary class]])
		return nil;
	
	bbsSignature_ = [rep objectForKey : kPropertyListBBSIdentifierKey];
	bbsSignature_ = [CMRBBSSignature objectWithPropertyListRepresentation : bbsSignature_];
	if(nil == bbsSignature_)
		return nil;
	
	identifier_ = [rep objectForKey : kPropertyListDATIdentifierKey];
	if(nil == identifier_)
		return nil;
	
	return [[self class] threadSignatureWithIdentifier : identifier_
										  BBSSignature : bbsSignature_];
}
- (id) propertyListRepresentation
{
	if(nil == [self identifier] || nil == [self BBSSignature])
		return [NSDictionary dictionary];
	
	return [NSDictionary dictionaryWithObjectsAndKeys :
				[self identifier], kPropertyListDATIdentifierKey,
				[[self BBSSignature] propertyListRepresentation],
				kPropertyListBBSIdentifierKey,
				nil];
}


- (NSString *) identifier
{
	return m_identifier;
}
- (CMRBBSSignature *) BBSSignature
{
	return m_BBSSignature;
}
- (NSString *) BBSName
{
	return [[self BBSSignature] name];
}

- (NSString *) filepathExceptsExtention
{
	NSString	*tmp_ = [[CMRDocumentFileManager defaultManager] directoryWithBoardName : [self BBSName]];
	return [tmp_ stringByAppendingPathComponent : [self identifier]];
	//return [[[self BBSSignature] dataRootDirectoryPath] stringByAppendingPathComponent : [self identifier]];
}
- (NSString *) datFilename
{
	return [[self identifier] 
				stringByAppendingPathExtension : CMRApp2chDATPathExtension];
}
- (NSString *) idxFileName
{
	return [[self identifier] 
				stringByAppendingPathExtension : CMRApp2chIdxPathExtension];
}
- (NSString *) localDATFilePath
{
	return [[self filepathExceptsExtention] 
		stringByAppendingPathExtension : CMRApp2chDATPathExtension];
}
- (NSString *) idxFilePath
{
	return [[self filepathExceptsExtention] 
		stringByAppendingPathExtension : CMRApp2chIdxPathExtension];
}
- (NSString *) threadDocumentPath
{
	NSString	*pathExtension_;
	
	pathExtension_ =
		[[CMRDocumentFileManager defaultManager] threadDocumentFileExtention];
	return [[self filepathExceptsExtention] 
		stringByAppendingPathExtension : pathExtension_];
}
@end



@implementation CMRThreadSignature(Private)
/* Accessor for m_identifier */
- (void) setIdentifier : (NSString *) anIdentifier
{
	id tmp;
	
	tmp = m_identifier;
	m_identifier = [anIdentifier retain];
	[tmp release];
}
/* Accessor for m_BBSSignature */
- (void) setBBSSignature : (CMRBBSSignature *) aBBSSignature
{
	id tmp;
	
	tmp = m_BBSSignature;
	m_BBSSignature = [aBBSSignature retain];
	[tmp release];
}
@end
