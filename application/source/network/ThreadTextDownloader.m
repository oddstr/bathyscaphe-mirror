//
//  ThreadTextDownloader.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/07/22.
//  Copyright 2007-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "ThreadTextDownloader_p.h"
#import "CMRDATDownloader.h"
#import "CMRThreadHTMLDownloader.h"
#import "DatabaseManager.h"

// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"


NSString *const ThreadTextDownloaderDidFinishLoadingNotification = @"ThreadTextDownloaderDidFinishLoadingNotification";
//NSString *const ThreadTextDownloaderUpdatedNotification = @"ThreadTextIsUpdated";
NSString *const ThreadTextDownloaderInvalidPerticalContentsNotification = @"ThreadTextDownloaderInvalidPerticalContentsNotification";
NSString *const CMRDownloaderUserInfoAdditionalInfoKey = @"AddtionalInfo";


@implementation ThreadTextDownloader
+ (Class *)classClusters
{
	static Class classes[3] = {Nil, };
	
	if (Nil == classes[0]) {
		classes[0] = [(id)[CMRDATDownloader class] retain];
		classes[1] = [(id)[CMRThreadHTMLDownloader class] retain];
		classes[2] = Nil;
	}
	
	return classes;
}

+ (id)downloaderWithIdentifier:(CMRThreadSignature *)signature
				   threadTitle:(NSString *)aTitle
					 nextIndex:(unsigned int) aNextIndex
{
	return [[[self alloc] initWithIdentifier:signature threadTitle:aTitle nextIndex:aNextIndex] autorelease];
}

- (id)initClusterWithIdentifier:(CMRThreadSignature *)signature
					threadTitle:(NSString *)aTitle
					  nextIndex:(unsigned int)aNextIndex
{
	if (self = [super init]) {
		[self setNextIndex:aNextIndex];
		[self setIdentifier:signature];
		m_threadTitle = [aTitle retain];
	}
	return self;
}
// do not release!
+ (id)allocWithZone:(NSZone *)zone
{
	if ([self isEqual:[ThreadTextDownloader class]]) {
		static id instance_;
		
		if (!instance_) {
			instance_ = [super allocWithZone:zone];
		}
		return instance_;
	}
	return [super allocWithZone:zone];
}

- (id)initWithIdentifier:(CMRThreadSignature *)signature
			 threadTitle:(NSString *)aTitle
			   nextIndex:(unsigned int)aNextIndex
{
	Class			*p;
	id				instance_;
	NSURL			*boardURL_;
	
	instance_ = nil;
	boardURL_ = [[BoardManager defaultManager] URLForBoardName:[signature boardName]];
	UTILRequireCondition(boardURL_, return_instance);
	
	for (p = [[self class] classClusters]; *p != Nil; p++) {
		if ([*p canInitWithURL:boardURL_]) {
			instance_ = [[*p alloc] initClusterWithIdentifier:signature threadTitle:aTitle nextIndex:aNextIndex];
			break;
		}
	}
	
return_instance:
	// [self release];
	return instance_;
}

- (void)dealloc
{	
	NSAssert2(
		NO == [(id)[self class] isEqual:(id)[ThreadTextDownloader class]],
		@"%@<%p> was place holder instance, do not release!!",
		NSStringFromClass([ThreadTextDownloader class]),
		self);

	[m_lastDateStore release];
	[m_localThreadsDict release];
	[m_threadTitle release];
	[super dealloc];
}

- (unsigned)nextIndex
{
	return m_nextIndex;
}

- (void)setNextIndex:(unsigned)aNextIndex
{
	m_nextIndex = aNextIndex;
}

- (NSDate *)lastDate
{
	return m_lastDateStore;
}

- (void)setLastDate:(NSDate *)date
{
	[date retain];
	[m_lastDateStore release];
	m_lastDateStore = date;
}

+ (BOOL)canInitWithURL:(NSURL *)url
{
	UTILAbstractMethodInvoked;
	return NO;
}

- (CFStringEncoding)CFEncodingForLoadedData
{
	CMRHostHandler	*handler_;
	
	handler_ = [CMRHostHandler hostHandlerForURL:[self boardURL]];
	return handler_ ? [handler_ threadEncoding] : 0;
}

- (NSStringEncoding)encodingForLoadedData
{
	CFStringEncoding	enc;
	
	enc = [self CFEncodingForLoadedData];
	return enc ? CF2NSEncoding(enc) : 0;
}

- (NSString *)contentsWithData:(NSData *)theData
{
	CFStringEncoding	enc;
	NSString			*src = nil;

	if (!theData || [theData length] == 0) return nil;
	
	enc = [self CFEncodingForLoadedData];
	src = [CMXTextParser stringWithData:theData CFEncoding:enc];
	
	if (!src) {
		NSLog(@"\n"
			@"*** WARNING ***\n\t"
			@"Can't convert the bytes\n\t"
			@"into Unicode characters(NSString). so retry TEC... "
			@"CFEncoding:%@", 
			(NSString*)CFStringConvertEncodingToIANACharSetName(enc));

		src = [[NSString alloc] initWithDataUsingTEC:theData encoding:CF2TextEncoding(enc)];
		[src autorelease];
	}
	return src;
}

- (CMRThreadSignature *)threadSignature
{
	return [self identifier];
}

- (NSString *)threadTitle
{
	return m_threadTitle;
}

- (NSURL *)threadURL
{
	UTILAbstractMethodInvoked;
	return nil;
}

- (NSDictionary *)localThreadsDict
{
	if (!m_localThreadsDict) {
		m_localThreadsDict = [[NSDictionary alloc] initWithContentsOfFile:[self filePathToWrite]];
	}
	return m_localThreadsDict;
}

#pragma mark Partial contents
- (BOOL)partialContentsRequested
{
	return ([[self localThreadsDict] objectForKey:ThreadPlistLengthKey] != nil);
}

// To cancel any background loading, cause partial contents was invalid.
- (void) cancelDownloadWithInvalidPartial
{
	[self cancelDownloadWithPostingNotificationName:ThreadTextDownloaderInvalidPerticalContentsNotification];
}

#pragma mark CMRDownloader
- (NSString *)filePathToWrite
{
	UTILAssertNotNil([self threadSignature]);
	return [[self threadSignature] threadDocumentPath];
}

- (NSURL *)resourceURL
{
	return [self threadURL];
}

- (NSURL *)boardURL
{
	UTILAssertNotNil([self threadSignature]);
	return [[BoardManager defaultManager] URLForBoardName:[[self threadSignature] boardName]];
}

- (NSURL *)resourceURLForWebBrowser
{
	return [self threadURL];
}
@end


@implementation ThreadTextDownloader(ThreadDataArchiver)
- (void)postDATFinishedNotificationWithContents:(NSString *)datContents
								 additionalInfo:(NSDictionary *)additionalInfo
{
	NSDictionary		*userInfo_;
	
	userInfo_ = [NSDictionary dictionaryWithObjectsAndKeys:
					datContents,		CMRDownloaderUserInfoContentsKey,
					[self resourceURL],	CMRDownloaderUserInfoResourceURLKey,
					[self identifier],	CMRDownloaderUserInfoIdentifierKey,
					additionalInfo,		CMRDownloaderUserInfoAdditionalInfoKey,
					nil];
	UTILNotifyInfo(
		ThreadTextDownloaderDidFinishLoadingNotification,
		userInfo_);
}

- (void)postUpdatedNotificationWithContents:(NSDictionary *)logContents
{
	NSDictionary	*userInfo_;
	
	userInfo_ = [NSDictionary dictionaryWithObjectsAndKeys:
					logContents,			CMRDownloaderUserInfoContentsKey,
					[self resourceURL],		CMRDownloaderUserInfoResourceURLKey,
					[self identifier],		CMRDownloaderUserInfoIdentifierKey,
					nil];
/*	UTILNotifyInfo(
		ThreadTextDownloaderUpdatedNotification,
		userInfo_);*/
	[[DatabaseManager defaultManager] threadTextDownloader:self didUpdateWithContents:userInfo_];
}

- (BOOL)synchronizeLocalDataWithContents:(NSString *)datContents
							  dataLength:(unsigned int)dataLength
{
    NSDictionary *thread;
	NSMutableDictionary *info_;
    BOOL          result = NO;    
    
    // can't process by downloader while viewer execute.
    if ([[CMRNetGrobalLock sharedInstance] has:[self identifier]]) {
        NSLog(@"[WARN] Thread %@ was already inProgress. "
              @"ThreadTextDownloader does nothing. at %@",
              [self identifier],
              UTIL_HANDLE_FAILURE_IN_METHOD);

        return YES;
    }

    thread = [self dictionaryByAppendingContents:datContents dataLength:dataLength];

	info_ = [NSMutableDictionary dictionary];
	[info_ setNoneNil:[thread objectForKey:ThreadPlistLengthKey] forKey:ThreadPlistLengthKey];
	[info_ setNoneNil:[thread objectForKey:CMRThreadModifiedDateKey] forKey:CMRThreadModifiedDateKey];

    // It guarantees that file must exists.
	if ([CMRPref saveThreadDocAsBinaryPlist]) {
		NSData *data_;
		NSString *errStr = [NSString string];
		data_ = [NSPropertyListSerialization dataFromPropertyList:thread format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errStr];

		if (!data_) {
			NSLog(@"NSPropertyListSerialization failed to convert to NSData. Reason:%@", errStr);
			result = NO;
		} else {
			result = [data_ writeToFile:[self filePathToWrite] atomically:YES];
		}
	} else {
		result = [thread writeToFile:[self filePathToWrite] atomically:YES];
	}

    [self postUpdatedNotificationWithContents:thread];
    [self postDATFinishedNotificationWithContents:datContents additionalInfo:info_];

    return result;
}

- (BOOL)amIAAThread
{
	NSDictionary	*localDict_ = [self localThreadsDict];
	if (!localDict_) {
		NSString *boardName = [[self threadSignature] boardName];
		if (boardName) {
			return [[BoardManager defaultManager] allThreadsShouldAAThreadAtBoard:boardName];
		} else {
			return NO;
		}
	}

	id					rep_;
	CMRThreadUserStatus	*s;
	
	rep_ = [localDict_ objectForKey:CMRThreadUserStatusKey];
	s = [CMRThreadUserStatus objectWithPropertyListRepresentation:rep_];
	return s ? [s isAAThread] : NO;
}

- (NSDictionary *)dictionaryByAppendingContents:(NSString *)datContents dataLength:(unsigned int)aLength
{
	NSDictionary			*localThread_;
	NSMutableDictionary		*newThread_;
	NSMutableArray			*messages_;
	CMRDocumentFileManager	*dfm;
	NSString				*filePath_;
	
	id<CMRMessageComposer>	composer_;
	CMR2chDATReader			*reader_;
	
	unsigned int			dataLength_;
	
	BOOL					shouldAA_ = NO;
	
	dataLength_ = aLength;
	localThread_ = [self localThreadsDict];
	if (!datContents || [datContents length] == 0) return localThread_;
	
	newThread_  = [NSMutableDictionary dictionary];
	messages_ = [NSMutableArray array];
	
	shouldAA_ = [self amIAAThread];

	composer_ = [CMRThreadPlistComposer composerWithThreadsArray:messages_ noteAAThread:shouldAA_];

	reader_ = [CMR2chDATReader readerWithContents:datContents];

	if (![self partialContentsRequested]) {
		[newThread_ setNoneNil:[reader_ threadTitle] forKey:CMRThreadTitleKey];
		[newThread_ setNoneNil:[reader_ firstMessageDate] forKey:CMRThreadCreatedDateKey];
	} else {		
		[newThread_ addEntriesFromDictionary:localThread_];
		[messages_ addObjectsFromArray:[newThread_ objectForKey:ThreadPlistContentsKey]];
		// 
		// We've been got extra 1 byte (for Abone-checking), so we need to adjust.
		//
		dataLength_ += [newThread_ unsignedIntForKey:ThreadPlistLengthKey];
		if (dataLength_ > 0) dataLength_--; // important
	}

	[newThread_ setUnsignedInt:dataLength_ forKey:ThreadPlistLengthKey];
	
	[reader_ setNextMessageIndex:[messages_ count]];
	[reader_ composeWithComposer:composer_];

	messages_ = [composer_ getMessages];
	
	if (![self lastDate]) {
		NSLog(@"lastDate is nil, so we use CMR2chDATReader's one.");
		[self setLastDate:[reader_ lastMessageDate]];
	}

	[newThread_ setNoneNil:[self lastDate] forKey:CMRThreadModifiedDateKey];
	[newThread_ setNoneNil:messages_ forKey:ThreadPlistContentsKey];
	
	dfm = [CMRDocumentFileManager defaultManager];
	filePath_ = [self filePathToWrite];
	[newThread_ setNoneNil:[dfm boardNameWithLogPath:filePath_] forKey:ThreadPlistBoardNameKey];
	[newThread_ setNoneNil:[dfm datIdentifierWithLogPath:filePath_] forKey:ThreadPlistIdentifierKey];
	
	return newThread_;
}
@end


@implementation ThreadTextDownloader(ResourceManagement)
- (void)synchronizeServerClock:(NSHTTPURLResponse *)response
{
	[super synchronizeServerClock:response];

	NSString *dateString2;
	NSDate *date2;

	dateString2 = [[response allHeaderFields] stringForKey:HTTP_LAST_MODIFIED_KEY];
	date2 = [NSCalendarDate dateWithHTTPTimeRepresentation:dateString2];

	[self setLastDate:date2];
}
@end


@implementation ThreadTextDownloader(Description)
- (NSString *)resourceName
{
	return [self threadTitle];
}
@end
