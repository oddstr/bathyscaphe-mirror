//
//  CMRThreadSignature.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/12/09.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadSignature.h"
#import "CMRDocumentFileManager.h"

static NSString *const kPropertyListBBSIdentifierKey = @"BBS";
static NSString *const kPropertyListDATIdentifierKey = @"DAT";


@interface CMRThreadSignature(Private)
- (void)setIdentifier:(NSString *)anIdentifier;
- (void)setBoardName:(NSString *)name;
@end


@implementation CMRThreadSignature(Private)
- (void)setIdentifier:(NSString *)anIdentifier
{
	[anIdentifier retain];
	[m_identifier release];
	m_identifier = anIdentifier;
}

- (void)setBoardName:(NSString *)name
{
	[name retain];
	[m_boardName release];
	m_boardName = name;
}
@end


@implementation CMRThreadSignature
+ (id)threadSignatureFromFilepath:(NSString *)filepath
{
	return [[[self alloc] initFromFilepath:filepath] autorelease];
}

- (id)initFromFilepath:(NSString *)filepath
{
	NSString			*boardName;
	NSString			*datIdentifier;
	CMRDocumentFileManager	*dfm = [CMRDocumentFileManager defaultManager];

	boardName = [dfm boardNameWithLogPath:filepath];
	datIdentifier = [dfm datIdentifierWithLogPath:filepath];

	return [self initWithIdentifier:datIdentifier boardName:boardName];
}

+ (id)threadSignatureWithIdentifier:(NSString *)identifier boardName:(NSString *)boardName
{
	return [[[self alloc] initWithIdentifier:identifier boardName:boardName] autorelease];
}

- (id)initWithIdentifier:(NSString *)identifier boardName:(NSString *)boardName
{
	if (!identifier || !boardName) {
		[self release];
		return nil;
	}

	if (self = [self init]) {
		[self setIdentifier:identifier];
		[self setBoardName:boardName];
	}
	return self;
}

- (void) dealloc
{
	[m_identifier release];
	[m_boardName release];
	[super dealloc];
}

#pragma mark NSObject
- (unsigned)hash
{
	return [[self boardName] hash] ^ [[self identifier] hash];
}

- (BOOL)isEqual:(id)other
{
	if ([super isEqual:other]) return YES;
	
	if ([other isKindOfClass:[self class]]){
		CMRThreadSignature	*other_ = other;
		id					obj1, obj2;
		BOOL				result = NO;
		
		obj1 = [self identifier];
		obj2 = [other_ identifier];
		result = (obj1 == obj2) ? YES : [obj1 isEqualToString:obj2];
		if (!result) return NO;
		
		obj1 = [self boardName];
		obj2 = [other_ boardName];
		result = (obj1 == obj2) ? YES : [obj1 isEqualToString:obj2];

		return result;
	}
	return NO;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@<identifier = %@, boardName = %@>", NSStringFromClass([self class]), [self identifier], [self boardName]];
}

#pragma mark CMRHistoryObject
- (BOOL)isHistoryEqual:(id)anObject
{
	return [self isEqual:anObject];
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	return [self retain];
}

#pragma mark CMRPropertyListCoding
+ (id)objectWithPropertyListRepresentation:(id)rep
{
	NSString	*bbsSignature_;
	NSString	*identifier_;
	
	if (![rep isKindOfClass:[NSDictionary class]]) return nil;
	
	bbsSignature_ = [rep objectForKey:kPropertyListBBSIdentifierKey];
	if (!bbsSignature_) return nil;
	
	identifier_ = [rep objectForKey:kPropertyListDATIdentifierKey];
	if (!identifier_) return nil;
	
	return [[self class] threadSignatureWithIdentifier:identifier_ boardName:bbsSignature_];
}

- (id)propertyListRepresentation
{
	if (![self identifier] || ![self boardName]) {
		return [NSDictionary dictionary];
	}
	return [NSDictionary dictionaryWithObjectsAndKeys:
				[self identifier], kPropertyListDATIdentifierKey,
				[self boardName], kPropertyListBBSIdentifierKey,
				NULL];
}

#pragma mark Accessors
- (NSString *)identifier
{
	return m_identifier;
}

- (NSString *)boardName
{
	return m_boardName;
}
/*
- (NSString *)filepathExceptsExtention
{
	NSString	*tmp_ = [[CMRDocumentFileManager defaultManager] directoryWithBoardName:[self boardName]];
	return [tmp_ stringByAppendingPathComponent:[self identifier]];
}
*/
- (NSString *)datFilename
{
	return [[self identifier] stringByAppendingPathExtension:CMRApp2chDATPathExtension];
}

- (NSString *)idxFileName
{
	return [[self identifier] stringByAppendingPathExtension:CMRApp2chIdxPathExtension];
}
/*
- (NSString *)localDATFilePath
{
	return [[self filepathExceptsExtention] stringByAppendingPathExtension:CMRApp2chDATPathExtension];
}

- (NSString *)idxFilePath
{
	return [[self filepathExceptsExtention] stringByAppendingPathExtension:CMRApp2chIdxPathExtension];
}
*/
- (NSString *)threadDocumentPath
{
	return [[CMRDocumentFileManager defaultManager] threadPathWithBoardName:[self boardName] datIdentifier:[self identifier]];
}
@end


@implementation CMRThreadSignature(Deprecated)
+ (id)threadSignatureWithIdentifier:(NSString *)anIdentifier BBSName:(NSString *)bbsName
{
	return [self threadSignatureWithIdentifier:anIdentifier boardName:bbsName];
}

- (id)initWithIdentifier:(NSString *)anIdentifier BBSName:(NSString *)bbsName
{
	return [self initWithIdentifier:anIdentifier BBSName:bbsName];
}

- (NSString *)BBSName
{
	return [self boardName];
}
@end
