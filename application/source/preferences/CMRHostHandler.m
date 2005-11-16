//: CMRHostHandler.m
/**
  * $Id: CMRHostHandler.m,v 1.2 2005/11/16 15:59:47 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRHostHandler_p.h"
#import "CMXTextParser.h"



#define kHostPropertiesFile		@"HostProperties.plist"


#define kHostNameKey				@"name"
#define kHostIdentifierKey			@"identifier"
#define kReadCGIPropertiesKey		@"CGI - Read"
	#define kRelativePathKey		@"relativePath"
	#define kAbsolutePathKey		@"absolutePath"
	// [[NSURL path] pathComponents] での directory のindex
	#define kReadCGIDirectoryIndexKey	@"directoryIndex"
	#define kReadCGINameKey				@"name"
	#define kReadCGIDirectoryKey		@"directory"
	#define kReadCGIParamBBSKey			@"bbs"
	#define kReadCGIParamIDKey			@"key"
	#define kReadCGIParamStartKey		@"start"
	#define kReadCGIParamEndKey			@"end"
	#define kReadCGIParamNoFirstKey		@"nofirst"
	#define kReadCGIParamTrueKey		@"true"

// DAT
#define kCanReadDATFileKey			@"DAT - Readable"
#define kRelativeDATDirectoryKey	@"DAT - RelativeDirectory"

// @see readURLWithBoard:datName:
#define READ_URL_FORMAT_DEF		@"%@?%@=%@&%@=%@"
#define READ_URL_FORMAT_2CH		@"%@/%s/%@/"
#define READ_URL_FORMAT_2CH_PARAM	@"%@/%s/%@/%@"
#define READ_URL_FORMAT_SHITARABA	@"%@/%@/%s/%@/"
#define READ_URL_FORMAT_SHITA_PARAM	@"%@/%@/%s/%@/%@"


@implementation CMRHostHandler
+ (SGBaseCArrayWrapper *) registeredHostHandlers
{
	static SGBaseCArrayWrapper *kRegisteredHostHandlers;
	
	if (nil == kRegisteredHostHandlers) {
		kRegisteredHostHandlers = [[SGBaseCArrayWrapper alloc] init];
	}
	return kRegisteredHostHandlers;
}

+ (void) registerAllKnownHostHandlerClasses
{
	[self registerHostHandlerClass : [CMR2channelBeHandler class]];
	[self registerHostHandlerClass : [CMR2channelHandler class]];
	[self registerHostHandlerClass : [CMRShitarabaHandler class]];
	[self registerHostHandlerClass : [CMRJbbsShitarabaHandler class]];
	[self registerHostHandlerClass : [CMRMachibbsaHandler class]];

	// 上記以外 = 2channel互換
	// datの改行を<br>にしていない板などが存在するので、サポートやめ
	[self registerHostHandlerClass : [CMR2channelOtherHandler class]];
}
+ (void) initialize
{
	static BOOL isFirst_ = YES;
	
	if (NO == isFirst_) return;
	isFirst_ = NO;
	
	[self registerAllKnownHostHandlerClasses];
}
+ (id) hostHandlerForURL : (NSURL *) anURL;
{
	SGBaseCArrayWrapper	*handlerArray_ = [self registeredHostHandlers];
	unsigned			nItems_ = SGBaseCArrayWrapperCount(handlerArray_);
	unsigned			index_;
	id					instance_;
	
	if (nil == anURL) return nil;
	
	for (index_ = 0; index_ < nItems_; index_++) {
		instance_ = SGBaseCArrayWrapperObjectAtIndex(handlerArray_, index_);
		if ([[instance_ class] canHandleURL : anURL]) {
			return instance_;
		}
	}
	return nil;
}

- (NSString *) description
{
	return [NSString stringWithFormat : 
						@"<%@ %p> identifier=%@ name=%@",
						[self className],
						self,
						[self identifier],
						[self name]];
}

// Managing subclasses

+ (BOOL) canHandleURL : (NSURL *) anURL
{
	UTILAbstractMethodInvoked;
	return NO;
}

+ (void) registerHostHandlerClass : (Class) aHostHandlerClass
{
	NSMutableArray		*handlerArray_ = [self registeredHostHandlers];
	NSEnumerator		*iter_ = [handlerArray_ objectEnumerator];
	id					instance_;
	
	UTILAssertNotNilArgument(aHostHandlerClass, @"HostHandler Class");
	// 既に登録されていないか
	while (instance_ = [iter_ nextObject]) {
		if ([(id)[instance_ class] isEqual : aHostHandlerClass]) {
			return;
		}
	}
	
	instance_ = [[aHostHandlerClass alloc] init];
	[handlerArray_ addObject : instance_];
	
	[instance_ release];
}


- (NSDictionary *) properties
{
	UTILAbstractMethodInvoked;
	return nil;
}
- (NSString *) name
{
	return [[self properties] objectForKey : kHostNameKey];
}
- (NSString *) identifier
{
	return [[self properties] objectForKey : kHostIdentifierKey];
}
- (NSDictionary *) readCGIProperties
{
	return [[self properties] objectForKey : kReadCGIPropertiesKey];
}

- (BOOL) canReadDATFile
{
	return [[self properties] boolForKey : kCanReadDATFileKey];
}

- (NSURL *) datURLWithBoard : (NSURL    *) boardURL
                    datName : (NSString *) datName
{
	NSString		*relativePath_;
	NSURL			*location_;
	
	UTILRequireCondition(boardURL && datName, ErrDATURL);
	UTILRequireCondition([self canReadDATFile], ErrDATURL);

	relativePath_ = [[self properties] objectForKey : kRelativeDATDirectoryKey];
	UTILRequireCondition(relativePath_, ErrDATURL);
	
	location_ = [NSURL URLWithString:relativePath_ relativeToURL:boardURL];
	location_ = [location_ URLByAppendingPathComponent : datName];
	
	return location_;
	
ErrDATURL:
	return nil;
}

- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
{
	id			property_;
	NSURL		*location_;
	
	UTILRequireCondition(boardURL, ErrReadURL);

	property_ = [[self readCGIProperties] objectForKey : kRelativePathKey];
	UTILRequireCondition(property_, ErrReadURL);
	location_ = [NSURL URLWithString:property_ relativeToURL:boardURL];
	
	return location_;
	
ErrReadURL:
	return nil;
}
- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
{
	NSString		*absolute_;
	NSURL			*location_;
	NSDictionary	*properties_;
	
	UTILRequireCondition(boardURL && datName, ErrReadURL);

	location_ = [self readURLWithBoard:boardURL];
	UTILRequireCondition(location_, ErrReadURL);
	
	properties_ = [self readCGIProperties];
	UTILRequireCondition(properties_, ErrReadURL);
	
	absolute_ = [NSString stringWithFormat :
					READ_URL_FORMAT_DEF,
					[location_ absoluteString],
					[properties_ objectForKey : kReadCGIParamBBSKey],
					[[boardURL absoluteString] lastPathComponent],
					[properties_ objectForKey : kReadCGIParamIDKey],
					datName];
	
	location_ = [NSURL URLWithString : absolute_];
	
	return location_;
	
ErrReadURL:
	return nil;
}

- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
					paramStr : (NSString *) paramStr
{
	return [self readURLWithBoard:boardURL datName:datName];
}

- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
					   start : (unsigned  ) startIndex
					     end : (unsigned  ) endIndex
					 nofirst : (BOOL      ) nofirst
{
	id				tmp;
	NSURL			*location_;
	NSDictionary	*properties_;
	NSString		*paramKey_;
	
	location_ = [self readURLWithBoard:boardURL datName:datName];
	UTILRequireCondition(location_, ErrReadURL);
	
	properties_ = [[self properties] objectForKey : kReadCGIPropertiesKey];
	UTILRequireCondition(properties_, ErrReadURL);
	
	tmp = SGTemporaryString();
	[tmp setString : [location_ absoluteString]];
	if (startIndex != NSNotFound) {
		paramKey_ = [properties_ objectForKey : kReadCGIParamStartKey];
		UTILAssertKindOfClass(paramKey_, NSString);
		
		[tmp appendFormat : @"&%@=%u", paramKey_, startIndex];
	}
	if (endIndex != NSNotFound) {
		paramKey_ = [properties_ objectForKey : kReadCGIParamEndKey];
		UTILAssertKindOfClass(paramKey_, NSString);
		
		[tmp appendFormat : @"&%@=%u", paramKey_, endIndex];
	}
	if (nofirst) {
		paramKey_ = [properties_ objectForKey : kReadCGIParamNoFirstKey];
		[tmp appendFormat : @"&%@=", paramKey_];
		paramKey_ = [properties_ objectForKey : kReadCGIParamTrueKey];
		[tmp appendString : paramKey_];
	}
	
	location_ = [NSURL URLWithString : tmp];
	
	return location_;
	
ErrReadURL:
	return nil;
}

/* エンコーディング関連 */
- (CFStringEncoding) subjectEncoding
{
	NSNumber	*v;
	
	v = [[self properties] numberForKey : @"SubjectEncoding"];
	return v ? [v unsignedIntValue] : kCFStringEncodingDOSJapanese;
}
- (CFStringEncoding) threadEncoding
{
	NSNumber	*v;
	
	v = [[self properties] numberForKey : @"ThreadEncoding"];
	return v ? [v unsignedIntValue] : kCFStringEncodingDOSJapanese;
}

- (NSURL *) boardURLWithURL : (NSURL    *) anURL
						bbs : (NSString *) bbs;
{
	if (nil == anURL || nil == bbs || [bbs isEmpty]) return nil;
	
	return [NSURL URLWithString : 
				[NSString stringWithFormat :
					@"http://%@/%@/", [anURL host], bbs]];
}
- (BOOL) parseParametersWithReadURL : (NSURL        *) link
                                bbs : (NSString    **) bbs
                                key : (NSString    **) key
                              start : (unsigned int *) startIndex
                                 to : (unsigned int *) endIndex
                          showFirst : (BOOL         *) showFirst
{
	NSArray		*comps_;
	id			tmp;
	
	NSString		*cgiName_;
	NSString		*directory_;
	unsigned		directoryIndex_;
	NSDictionary*	properties_;
	
	if (bbs != NULL) *bbs = nil;
	if (key != NULL) *key = nil;
	if (startIndex != NULL) *startIndex = NSNotFound;
	if (endIndex != NULL) *endIndex = NSNotFound;
	if (showFirst != NULL) *showFirst = YES;
		
	//--------------------------------
/*
	UTILMethodLog;
	UTILDescription(link);
*/
	//--------------------------------
	
	UTILRequireCondition(link, ErrParse);
	UTILRequireCondition(
		[[self class] canHandleURL : link],
		ErrParse);
	
	properties_ = [self readCGIProperties];
	tmp = [properties_ objectForKey : kReadCGIDirectoryIndexKey];
	UTILAssertKindOfClass(tmp, NSNumber);
	directoryIndex_ = [tmp unsignedIntValue];
	
	cgiName_ = [properties_ objectForKey : kReadCGINameKey];
	UTILAssertKindOfClass(cgiName_, NSString);
	directory_ = [properties_ objectForKey : kReadCGIDirectoryKey];
	UTILAssertKindOfClass(directory_, NSString);
	
	comps_ = [[link path] pathComponents];

	//--------------------------------
/*
	UTILDescUnsignedInt(directoryIndex_);
	UTILDescription(cgiName_);
	UTILDescription(directory_);
*/
	//--------------------------------

	UTILRequireCondition(
		([comps_ count] > directoryIndex_ +1), ErrParse);
	
	// ディレクトリとCGIの名前
	tmp = [comps_ objectAtIndex : directoryIndex_];
	//--------------------------------
/*
	UTILDescString1(tmp);
*/
	//--------------------------------
	UTILRequireCondition([tmp isEqualToString : directory_], ErrParse);
	tmp = [comps_ objectAtIndex : directoryIndex_ +1];
	//--------------------------------
/*
	UTILDescString1(tmp, @"[comps_ objectAtIndex : directoryIndex_ +1]");
	UTILDescBoolean([tmp hasPrefix : cgiName_]);
*/
	//--------------------------------
	UTILRequireCondition([tmp hasPrefix : cgiName_], ErrParse);

	
	// クエリによるパラメータ指定ならそれを解析。
	// そうでなければ、最後のパス要素をスキャン。
	if ([link query] != nil) {
		NSDictionary	*params_;
		NSString		*bbs_;
		NSString		*key_;
		NSString		*st_;
		NSString		*to_;
		NSString		*nofirst_;
		
		params_ = [link queryDictionary];
		UTILRequireCondition(params_, ErrParse);
		

		tmp = [properties_ objectForKey : kReadCGIParamBBSKey];
		bbs_ = [params_ objectForKey : tmp];
		//--------------------------------
/*
		UTILDescString1(tmp, kReadCGIParamBBSKey);
		UTILDescString(bbs_);
*/
		//--------------------------------
		if (nil == bbs_) return NO;
		if (bbs != NULL) *bbs = bbs_;
		
		tmp = [properties_ objectForKey : kReadCGIParamIDKey];
		key_ = [params_ objectForKey : tmp];
		//--------------------------------
/*
		UTILDescString1(tmp, kReadCGIParamIDKey);
		UTILDescString(key_);
*/
		//--------------------------------
		if (nil == key_) return NO;
		if (key != NULL) *key = key_;

		tmp = [properties_ objectForKey : kReadCGIParamStartKey];
		st_ = [params_ objectForKey : tmp];
		if (startIndex != NULL)
			*startIndex = st_ ? [st_ intValue] : NSNotFound;

		tmp = [properties_ objectForKey : kReadCGIParamEndKey];
		to_ = [params_ objectForKey : tmp];
		if (endIndex != NULL) 
			*endIndex = to_ ? [to_ intValue] : NSNotFound;

		tmp = [properties_ objectForKey : kReadCGIParamNoFirstKey];
		nofirst_ = [params_ objectForKey : tmp];
		
		tmp = [properties_ objectForKey : kReadCGIParamTrueKey];
		if (nil == nofirst_) nofirst_ = tmp;
		
		if (showFirst != NULL)
			*showFirst = (NO == [nofirst_ isEqualToString : tmp]);
		
		
		return YES;
		
	}else if ([comps_ count] > directoryIndex_ + 3) {
		if (bbs != NULL) *bbs = [comps_ objectAtIndex : directoryIndex_ + 2];
		if (key != NULL) *key = [comps_ objectAtIndex : directoryIndex_ + 3];
		if ([comps_ count] > directoryIndex_ + 4) {
			NSString  *mesIndexStr_;
			NSScanner *scanner_;
			NSString  *skiped_;
			int index_;
			
			skiped_ = nil;
			
			// 最後のパス文字列がインデックス文字列
			// になっているので、そこからインデックス
			// をスキャン
			mesIndexStr_ = [comps_ lastObject];
			scanner_ = [NSScanner scannerWithString : mesIndexStr_];
			[scanner_ scanUpToCharactersFromSet : 
						[NSCharacterSet decimalDigitCharacterSet] 
					  intoString : &skiped_];
			if ([scanner_ scanInt : &index_]) {
				if (startIndex != NULL) *startIndex = index_;
				if (endIndex != NULL) *endIndex = index_;
				
				// 範囲が指定されているか
				if ([scanner_ scanString : @"-" intoString : NULL]) {
					if ([scanner_ scanInt : &index_]) {
						if (endIndex != NULL) *endIndex = index_;
					}
				}
			}
			if (showFirst != NULL) *showFirst = NO;
		}
			return YES;
	}
	

ErrParse:
	return NO;
}

- (id) parseHTML : (NSString *) inputSource
			with : (id        ) thread
		   count : (unsigned  ) loadedCount
{
	UTILAbstractMethodInvoked;
	return nil;
}
@end


@implementation CMRHostHandler(WriteCGI)
#define kWriteCGIPropertiesKey		@"CGI - Write"
#define kFormKeyDictKey				@"FormKeys"
#define kWriteCGISubmitValueKey		@"submitValue"

// write.cgi
- (NSDictionary *) writeCGIProperties
{
	return [[self properties] objectForKey : kWriteCGIPropertiesKey];
}
- (NSDictionary *) formKeyDictionary
{
	return [[self writeCGIProperties] dictionaryForKey : kFormKeyDictKey];
}
- (NSURL *) writeURLWithBoard : (NSURL *) boardURL
{
	NSString	*path_;
	
	if (nil == boardURL) return nil;
	
	path_ = [[self writeCGIProperties] stringForKey : kRelativePathKey];
	if (path_ != nil)
		return [NSURL URLWithString : path_
					  relativeToURL : boardURL];

	path_ = [[self writeCGIProperties] stringForKey : kAbsolutePathKey];
	if (path_ != nil)
		return [NSURL URLWithString : path_];
	
	return nil;
}
- (NSString *) submitValue
{
	return [[self writeCGIProperties] stringForKey : kWriteCGISubmitValueKey];
}
@end



static NSDictionary *CMRHostPropertiesForKey(NSString *aKey)
{
	static NSDictionary		*allProperties_;
	
	if (nil == allProperties_)
		allProperties_ = [[NSBundle mergedDictionaryWithName : kHostPropertiesFile] retain];
	
	return [allProperties_ dictionaryForKey : aKey];
}



// ２ちゃんねる
@implementation CMR2channelHandler : CMRHostHandler
+ (BOOL) canHandleURL : (NSURL *) anURL
{
	const char *hs = [[anURL host] UTF8String];
	
	if (NULL == hs)
		return NO;
	
	return is_2channel(hs);
}
- (NSDictionary *) properties
{
	return CMRHostPropertiesForKey(@"2channel");
}
- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
{
	NSString		*absolute_;
	const char		*bbs_ = NULL;
	NSURL			*location_;
	NSDictionary	*properties_;
	
	UTILRequireCondition(boardURL && datName, ErrReadURL);

	location_ = [self readURLWithBoard:boardURL];
	UTILRequireCondition(location_, ErrReadURL);
	
	properties_ = [self readCGIProperties];
	UTILRequireCondition(properties_, ErrReadURL);
	
	CMRGetHostCStringFromBoardURL(boardURL, &bbs_);
	UTILRequireCondition(bbs_, ErrReadURL);

	absolute_ = [NSString stringWithFormat :
					READ_URL_FORMAT_2CH,
					[location_ absoluteString],
					bbs_,
					datName];
	
	location_ = [NSURL URLWithString : absolute_];
	
	return location_;
	
ErrReadURL:
	return nil;
}
- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
					paramStr : (NSString *) paramStr
{
	NSString		*absolute_;
	const char		*bbs_ = NULL;
	NSURL			*location_;
	NSDictionary	*properties_;
	
	UTILRequireCondition(boardURL && datName, ErrReadURL);

	location_ = [self readURLWithBoard:boardURL];
	UTILRequireCondition(location_, ErrReadURL);
	
	properties_ = [self readCGIProperties];
	UTILRequireCondition(properties_, ErrReadURL);
	
	CMRGetHostCStringFromBoardURL(boardURL, &bbs_);
	UTILRequireCondition(bbs_, ErrReadURL);

	absolute_ = [NSString stringWithFormat :
					READ_URL_FORMAT_2CH_PARAM,
					[location_ absoluteString],
					bbs_,
					datName,
					paramStr];
	
	location_ = [NSURL URLWithString : absolute_];
	
	return location_;
	
ErrReadURL:
	return nil;
}

- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
					   start : (unsigned  ) startIndex
					     end : (unsigned  ) endIndex
					 nofirst : (BOOL      ) nofirst
{
	id				tmp;
	NSURL			*location_;
	
	location_ = [self readURLWithBoard:boardURL datName:datName];
	UTILRequireCondition(location_, ErrReadURL);
	
	tmp = SGTemporaryString();
	[tmp setString : [location_ absoluteString]];
	if (startIndex != NSNotFound)
		[tmp appendFormat : @"%u", startIndex];
	
	if (endIndex != NSNotFound && endIndex != startIndex) {
		if (NSNotFound == startIndex)
			[tmp appendString : @"1"];
		
		[tmp appendFormat : @"-%u", endIndex];
	}
	if (nofirst) {
/*
		paramKey_ = [properties_ objectForKey : kReadCGIParamNoFirstKey];
		[tmp appendFormat : @"&%@=", paramKey_];
		paramKey_ = [properties_ objectForKey : kReadCGIParamTrueKey];
		[tmp appendString : paramKey_];
*/
	}
	
	location_ = [NSURL URLWithString : tmp];
	
	return location_;
	
ErrReadURL:
	return nil;
}
@end

// ２ちゃんねる互換
@implementation CMR2channelOtherHandler
+ (BOOL) canHandleURL : (NSURL *) anURL
{
	const char *hs = [[anURL host] UTF8String];
	
	if (NULL == hs)
		return NO;
	
	return YES;
}
@end

// Be@2ch
@implementation CMR2channelBeHandler : CMR2channelHandler
+ (BOOL) canHandleURL : (NSURL *) anURL
{
	const char *hs = [[anURL host] UTF8String];
	
	if (NULL == hs)
		return NO;
	
	return is_be2ch( hs );
}
- (NSDictionary *) properties
{
	return CMRHostPropertiesForKey(@"Be@2channel");
}
@end


// したらば
@implementation CMRShitarabaHandler : CMRHostHandler
+ (BOOL) canHandleURL : (NSURL *) anURL
{
	const char *hostName_ = [[anURL host] UTF8String];
         if ( NULL == hostName_ ) return NO;
	return is_shitaraba( hostName_ );
}
- (NSDictionary *) properties
{
	return CMRHostPropertiesForKey(@"shitaraba");
}
@end


// JBBS@したらば
@implementation CMRJbbsShitarabaHandler : CMRHostHTMLHandler
+ (BOOL) canHandleURL : (NSURL *) anURL
{
	const char *hostName_ = [[anURL host] UTF8String];
         if ( NULL == hostName_ ) return NO;
	return is_jbbs_shita( hostName_ );
}
- (NSDictionary *) properties
{
	return CMRHostPropertiesForKey(@"jbbs_shita");
}
- (NSURL *) boardURLWithURL : (NSURL    *) anURL
						bbs : (NSString *) bbs;
{
	NSString	*absolute_;
	NSArray		*paths_;
	
	paths_ = [[anURL path] pathComponents];
	if ([paths_ count] < 2)
		return nil;
	
	absolute_ = [NSString stringWithFormat :
					@"http://%@/%@/%@/",
					[anURL host],
					bbs,
					[paths_ objectAtIndex : 1]];
	
	return [NSURL URLWithString : absolute_];
}
- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
{
	NSString		*absolute_;
	const char		*bbs_ = NULL;
	NSURL			*location_;
	NSDictionary	*properties_;
	
	UTILRequireCondition(boardURL && datName, ErrReadURL);

	location_ = [self readURLWithBoard:boardURL];
	UTILRequireCondition(location_, ErrReadURL);
	
	properties_ = [self readCGIProperties];
	UTILRequireCondition(properties_, ErrReadURL);
	
	CMRGetHostCStringFromBoardURL(boardURL, &bbs_);
	UTILRequireCondition(bbs_, ErrReadURL);

	absolute_ = [NSString stringWithFormat :
					READ_URL_FORMAT_SHITARABA,
					[location_ absoluteString],
					[[[boardURL path] pathComponents] objectAtIndex : 1],
					bbs_,
					datName];
	
	location_ = [NSURL URLWithString : absolute_];
	
	return location_;
	
ErrReadURL:
	return nil;
}
- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
					paramStr : (NSString *) paramStr
{
	NSString		*absolute_;
	const char		*bbs_ = NULL;
	NSURL			*location_;
	NSDictionary	*properties_;
	
	UTILRequireCondition(boardURL && datName, ErrReadURL);

	location_ = [self readURLWithBoard:boardURL];
	UTILRequireCondition(location_, ErrReadURL);
	
	properties_ = [self readCGIProperties];
	UTILRequireCondition(properties_, ErrReadURL);
	
	CMRGetHostCStringFromBoardURL(boardURL, &bbs_);
	UTILRequireCondition(bbs_, ErrReadURL);

	absolute_ = [NSString stringWithFormat :
					READ_URL_FORMAT_SHITA_PARAM,
					[location_ absoluteString],
					[[[boardURL path] pathComponents] objectAtIndex : 1],
					bbs_,
					datName,
					paramStr];
	
	location_ = [NSURL URLWithString : absolute_];
	
	return location_;
	
ErrReadURL:
	return nil;
}
- (NSURL *) readURLWithBoard : (NSURL    *) boardURL
                     datName : (NSString *) datName
					   start : (unsigned  ) startIndex
					     end : (unsigned  ) endIndex
					 nofirst : (BOOL      ) nofirst
{
	id				tmp;
	NSURL			*location_;
	
	location_ = [self readURLWithBoard:boardURL datName:datName];
	UTILRequireCondition(location_, ErrReadURL);
	
	tmp = SGTemporaryString();
	[tmp setString : [location_ absoluteString]];
	if (startIndex != NSNotFound)
		[tmp appendFormat : @"%u-", startIndex];
	
	if (endIndex != NSNotFound && endIndex != startIndex) {
		if (NSNotFound == startIndex)
			[tmp appendString : @"1-"];
		
		[tmp appendFormat : @"%u", endIndex];
	}
	if (nofirst) {
			[tmp appendString : @"n"];
	}
	
	location_ = [NSURL URLWithString : tmp];
	
	return location_;
	
ErrReadURL:
	return nil;
}
@end



// まちBBS
@implementation CMRMachibbsaHandler : CMRHostHTMLHandler
+ (BOOL) canHandleURL : (NSURL *) anURL
{
	const char *hostName_ = [[anURL host] UTF8String];
         if ( NULL == hostName_ ) return NO;
	return is_machi( hostName_ );
}
- (NSDictionary *) properties
{
	return CMRHostPropertiesForKey(@"machibbs");
}
@end
