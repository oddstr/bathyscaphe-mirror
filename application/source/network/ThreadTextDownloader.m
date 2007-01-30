/**
  * $Id: ThreadTextDownloader.m,v 1.4 2007/01/30 14:04:11 tsawada2 Exp $
  * 
  * ThreadTextDownloader.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "ThreadTextDownloader_p.h"
#import "CMRDATDownloader.h"
#import "CMRThreadHTMLDownloader.h"



// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"



// ----------------------------------------
//  N o t i f i c a t i o n
// ----------------------------------------
NSString *const ThreadTextDownloaderDidFinishLoadingNotification = @"ThreadTextDownloaderDidFinishLoadingNotification";
NSString *const ThreadTextDownloaderUpdatedNotification = @"ThreadTextIsUpdated";
NSString *const ThreadTextDownloaderInvalidPerticalContentsNotification = @"ThreadTextDownloaderInvalidPerticalContentsNotification";
NSString *const CMRDownloaderUserInfoAdditionalInfoKey = @"AddtionalInfo";


@implementation ThreadTextDownloader
+ (Class *) classClusters
{
	static Class classes[3] = {Nil, };
	
	if (Nil == classes[0]) {
		classes[0] = [(id)[CMRDATDownloader class] retain];
		classes[1] = [(id)[CMRThreadHTMLDownloader class] retain];
		classes[2] = Nil;
	}
	
	return classes;
}
+ (id) downloaderWithIdentifier : (CMRThreadSignature *) signature
					threadTitle : (NSString           *) aTitle
					  nextIndex : (unsigned int        ) aNextIndex
{
	return [[[self alloc] initWithIdentifier : signature 
								 threadTitle : aTitle
								   nextIndex : aNextIndex] autorelease];
}

- (id) initClusterWithIdentifier : (CMRThreadSignature *) signature
					 threadTitle : (NSString           *) aTitle
					   nextIndex : (unsigned int        ) aNextIndex
{
	if (self = [super init]) {
		[self setNextIndex : aNextIndex];
		[self setIdentifier : signature];
		_threadTitle = [aTitle retain];
	}
	return self;;
}
// do not release!
+ (id) allocWithZone : (NSZone *) zone
{
	if ([self isEqual : [ThreadTextDownloader class]]) {
		static id instance_;
		
		if (nil == instance_)
			instance_ = [super allocWithZone : zone];
		
		return instance_;
	}
	return [super allocWithZone : zone];
}
- (id) initWithIdentifier : (CMRThreadSignature *) signature
			  threadTitle : (NSString           *) aTitle
				nextIndex : (unsigned int        ) aNextIndex
{
	Class			*p;
	id				instance_;
	NSURL			*boardURL_;
	
	instance_ = nil;
	boardURL_ = [[BoardManager defaultManager] URLForBoardName : [signature BBSName]];
	UTILRequireCondition(boardURL_, return_instance);
	
	for (p = [[self class] classClusters]; *p != Nil; p++) {
		if ([*p canInitWithURL : boardURL_]) {
			instance_ = [[*p alloc] initClusterWithIdentifier:signature threadTitle:aTitle nextIndex:aNextIndex];
			break;
		}
	}
	
return_instance:
	// [self release];
	return instance_;
}

- (void) dealloc
{	
	NSAssert2(
		NO == [(id)[self class] isEqual : (id)[ThreadTextDownloader class]],
		@"%@<%p> was place holder instance, do not release!!",
		NSStringFromClass([ThreadTextDownloader class]),
		self);
	
	[_localThreadsDict release];
	[_threadTitle release];
	[super dealloc];
}

- (unsigned) nextIndex
{
	return _nextIndex;
}
- (void) setNextIndex : (unsigned) aNextIndex
{
	_nextIndex = aNextIndex;
}

+ (BOOL) canInitWithURL : (NSURL *) url
{
	UTILAbstractMethodInvoked;
	return NO;
}

- (CFStringEncoding) CFEncodingForLoadedData
{
	CMRHostHandler	*handler_;
	
	handler_ = [CMRHostHandler hostHandlerForURL : [self boardURL]];
	return handler_ ? [handler_ threadEncoding] : 0;
}
- (NSStringEncoding) encodingForLoadedData
{
	CFStringEncoding	enc;
	
	enc = [self CFEncodingForLoadedData];
	return enc ? CF2NSEncoding(enc) : 0;
}
- (NSString *) contentsWithData : (NSData *) theData
{
	CFStringEncoding	enc;
	NSString			*src = nil;
	
	if (nil == theData || 0 == [theData length]) return nil;
	
	//CMRDebugWriteObject(theData, @"thread.txt");
	enc = [self CFEncodingForLoadedData];
	src = [CMXTextParser stringWithData:theData CFEncoding:enc];
	
	if (nil == src) {
		NSLog(@"\n"
			@"*** WARNING ***\n\t"
			@"Can't convert the bytes(saved as thread.txt in Logs directory)\n\t"
			@"into Unicode characters(NSString). so retry TEC... "
			@"CFEncoding:%@", 
			(NSString*)CFStringConvertEncodingToIANACharSetName(enc));
		
		src = [[NSString alloc] initWithDataUsingTEC:theData 
							encoding:CF2TextEncoding(enc)];
		[src autorelease];
	}
	return src;
}

- (CMRThreadSignature *) threadSignature
{
	return [self identifier];
}
- (NSString *) threadTitle
{
	return _threadTitle;
}
- (NSURL *) threadURL
{
	UTILAbstractMethodInvoked;
	return nil;
}
- (NSDictionary *) localThreadsDict
{
	if (nil == _localThreadsDict)
		_localThreadsDict = [[NSDictionary alloc] initWithContentsOfFile : [self filePathToWrite]];
	
	return _localThreadsDict;
}



// ----------------------------------------
// Partial contents
// ----------------------------------------
- (BOOL) pertialContentsRequested;
{
	return ([[self localThreadsDict] objectForKey : ThreadPlistLengthKey] != nil);
}
// Called by URLHandle:resourceDataDidBecomeAvailable:
// to cancel any background loading, cause partial contents was invalid.
- (void) cancelDownloadWithInvalidPartial
{
	[self cancelDownloadWithPostingNotificationName :
				ThreadTextDownloaderInvalidPerticalContentsNotification];
}


// CMRDownloader
- (NSString *) filePathToWrite
{
	UTILAssertNotNil([self threadSignature]);
	return [[self threadSignature] threadDocumentPath];
}
- (NSURL *) resourceURL
{
	return [self threadURL];
}
- (NSURL *) boardURL
{
	UTILAssertNotNil([self threadSignature]);
	return [[BoardManager defaultManager] URLForBoardName : [[self threadSignature] BBSName]];
}
- (NSURL *) resourceURLForWebBrowser
{
	return [self threadURL];
}
@end



@implementation ThreadTextDownloader(ThreadDataArchiver)
- (void) postDATFinishedNotificationWithContents: (NSString *) datContents
								  additionalInfo: (NSDictionary *) additionalInfo
{
	NSDictionary		*userInfo_;
	
	userInfo_ = [NSDictionary dictionaryWithObjectsAndKeys :
					datContents,		CMRDownloaderUserInfoContentsKey,
					[self resourceURL],	CMRDownloaderUserInfoResourceURLKey,
					[self identifier],	CMRDownloaderUserInfoIdentifierKey,
					additionalInfo,		CMRDownloaderUserInfoAdditionalInfoKey,
					nil];
	UTILNotifyInfo(
		ThreadTextDownloaderDidFinishLoadingNotification,
		userInfo_);
}
- (void) postUpdatedNotificationWithContents : (NSDictionary *) logContents
{
	NSDictionary	*userInfo_;
	
	userInfo_ = [NSDictionary dictionaryWithObjectsAndKeys :
					logContents,			CMRDownloaderUserInfoContentsKey,
					[self resourceURL],		CMRDownloaderUserInfoResourceURLKey,
					[self identifier],		CMRDownloaderUserInfoIdentifierKey,
					nil];
	UTILNotifyInfo(
		ThreadTextDownloaderUpdatedNotification,
		userInfo_);
}
- (BOOL) synchronizeLocalDataWithContents : (NSString   *) datContents
							   dataLength : (unsigned int) dataLength
{
    NSDictionary *thread;
	NSMutableDictionary *info_;
    BOOL          result = NO;
    
    
    // can't process by downloader while viewer execute.
    if ([[CMRNetGrobalLock sharedInstance] has : [self identifier]]) {
        NSLog(@"[WARN] Thread %@ was already inProgress. "
              @"ThreadTextDownloader does nothing. at %@",
              [self identifier],
              UTIL_HANDLE_FAILURE_IN_METHOD);

        return YES;
    }
    thread = [self dictionaryByAppendingContents : datContents
                   dataLength : dataLength];

	info_ = [NSMutableDictionary dictionary];
	[info_ setNoneNil: [thread objectForKey: ThreadPlistLengthKey] forKey: ThreadPlistLengthKey];
	[info_ setNoneNil: [thread objectForKey: CMRThreadModifiedDateKey] forKey: CMRThreadModifiedDateKey];

    // It guarantees that file must exists.
    result = [thread writeToFile : [self filePathToWrite]
                                  atomically : YES];
    
    [self postUpdatedNotificationWithContents : thread];
    [self postDATFinishedNotificationWithContents: datContents additionalInfo: info_];
    
    return result;
}

- (BOOL) amIAAThread : (NSDictionary *) localDict_
{
	if (!localDict_) {
		NSString *boardName_ = [[self threadSignature] BBSName];
		if (boardName_) return [[BoardManager defaultManager] allThreadsShouldAAThreadAtBoard : boardName_];
		else return NO;
	}

	id					rep_;
	CMRThreadUserStatus	*s;
	
	rep_ = [localDict_ objectForKey : CMRThreadUserStatusKey];
	s = [CMRThreadUserStatus objectWithPropertyListRepresentation : rep_];
	return s ? [s isAAThread] : NO;
}

- (NSDictionary *) dictionaryByAppendingContents : (NSString   *) datContents
									  dataLength : (unsigned int) aLength;
{
	NSDictionary			*localThread_;
	NSMutableDictionary		*newThread_;
	NSMutableArray			*messages_;
	NSDate					*lastDate_;
	id						v;
	
	id<CMRMessageComposer>	composer_;
	CMR2chDATReader			*reader_;
	
	unsigned int			dataLength_;
	
	BOOL					shouldAA_ = NO;
	
	dataLength_ = aLength;
	localThread_ = [self localThreadsDict];
	if (nil == datContents || 0 == [datContents length]) return localThread_;
	
	newThread_  = [NSMutableDictionary dictionary];
	messages_ = [NSMutableArray array];
	
	shouldAA_ = [self amIAAThread : localThread_];

	//composer_ = [CMRThreadPlistComposer composerWithThreadsArray : messages_];
	composer_ = [CMRThreadPlistComposer composerWithThreadsArray : messages_ noteAAThread : shouldAA_];

	reader_ = [CMR2chDATReader readerWithContents : datContents];
	if (NO == [self pertialContentsRequested]) {
		[newThread_ setNoneNil : [reader_ threadTitle]
						forKey : CMRThreadTitleKey];
		[newThread_ setNoneNil : [reader_ firstMessageDate]
						forKey : CMRThreadCreatedDateKey];
	} else {
		
		[newThread_ addEntriesFromDictionary : localThread_];
		[messages_ addObjectsFromArray :
			[newThread_ objectForKey : ThreadPlistContentsKey]];
		



		// 
		// あぽーん対策で余分に1バイト取得しているので、
		// ここで前回の分と足しあわせて調整する。
		//
		dataLength_ += [[newThread_ objectForKey : ThreadPlistLengthKey] intValue];
		if (dataLength_ > 0) dataLength_--;
	}
	[newThread_ setObject : [NSNumber numberWithUnsignedInt : dataLength_]
				   forKey : ThreadPlistLengthKey];
	
	[reader_ setNextMessageIndex : [messages_ count]];
	[reader_ composeWithComposer : composer_];

	messages_ = [composer_ getMessages];
	
	// 最後のレスの日付けを取得。
	// サーバからのレスポンスに最終更新日が含まれていない場合は
	// 最後のレスの書き込み日時で判断する。
	// 最後のレスがあぼーん、Over 1000 Threadなどの場合は直前のレスの日付けを取得
	lastDate_ = nil;
	{
		SGHTTPConnector	*connector_;
		NSString		*lastmdate_;
		
		connector_ = [self currentConnector];
		lastmdate_ = [[connector_ response] headerFieldValueForKey : HTTP_LAST_MODIFIED_KEY];
		lastDate_ = [NSCalendarDate dateWithHTTPTimeRepresentation : lastmdate_];
		
	}
	if (nil == lastDate_) lastDate_ = [reader_ lastMessageDate];
	[newThread_ setNoneNil : lastDate_
					forKey : CMRThreadModifiedDateKey];
	[newThread_ setNoneNil : messages_
					forKey : ThreadPlistContentsKey];
	
	v = [CMRDocumentFileManager defaultManager];
 	v = [v boardNameWithLogPath : [self filePathToWrite]];
	[newThread_ setNoneNil:v forKey:ThreadPlistBoardNameKey];
	
	v = [CMRDocumentFileManager defaultManager];
	v = [v datIdentifierWithLogPath : [self filePathToWrite]];
	[newThread_ setNoneNil:v forKey:ThreadPlistIdentifierKey];
	
	return newThread_;
}
@end



@implementation ThreadTextDownloader(Description)
- (NSString *) resourceName
{
	return [self threadTitle];
}
@end
