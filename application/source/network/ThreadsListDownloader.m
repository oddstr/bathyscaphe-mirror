/**
 * $Id: ThreadsListDownloader.m,v 1.3 2005/09/30 01:08:32 tsawada2 Exp $
 * 
 * ThreadsListDownloader.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */
#import "ThreadsListDownloader.h"

#import "CMRDownloader_p.h"
#import "AppDefaults.h"
#import "BoardManager.h"
#import "CMRBBSSignature.h"
#import "CMRThreadSubjectComposer.h"
#import "CMRDocumentFileManager.h"

#import "CMRSubjectReader.h"
#import "CMRHostHandler.h"



// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"



///////////////////////////////////////////////////////////////
//////////////////// [ C o n s t a n t s ] ////////////////////
///////////////////////////////////////////////////////////////
NSString *const ThreadListDownloaderUpdatedNotification = @"ThreadListDownloaderUpdatedNotification";
NSString *const ThreadsListDownloaderShouldRetryUpdateNotification = @"ThreadsListDownloaderShouldRetryUpdateNotification";


// detect moved bbs address x times.
#define MAX_TRYDETECT_COUNT    2



@implementation ThreadsListDownloader
+ (id) threadsListDownloaderWithBBSSignature : (CMRBBSSignature *) signature
{
	return [[[self alloc] initWithBBSSignature : signature] autorelease];
}

- (id) initWithBBSSignature : (CMRBBSSignature *) signature
{
	NSURL	*boardURL_;
	
	boardURL_ = [[BoardManager defaultManager] URLForBoardName : [signature name]];
	if (NO == [[self class] canInitWithURL : boardURL_]) {
		[self autorelease];
		return nil;
	}
	
	if (self = [super init]) {
		[self setBBSSignature : signature];
	}
	return self;
}


+ (BOOL) canInitWithURL : (NSURL *) url
{
	return ([CMRHostHandler hostHandlerForURL : url] != nil);
}
+ (BOOL) isValideSubjectTXT : (NSString *) contents
{
	NSRange found;
	
	found = [contents rangeOfString : @"<HTML"
							options : NSCaseInsensitiveSearch]; 
	
	return (found.location == NSNotFound);
}


- (CMRBBSSignature *) BBSSignature
{
	return [self identifier];
}
- (void) setBBSSignature : (CMRBBSSignature *) aBBSSignature
{
	[self setIdentifier : aBBSSignature];
}

@end



@implementation ThreadsListDownloader(Accessor)
- (NSString *) filePathToWrite
{
	//return [[self BBSSignature] threadsListPlistPath];
	return [[CMRDocumentFileManager defaultManager] threadsListPathWithBoardName : [[self BBSSignature] name]];
}
- (NSURL *) resourceURL
{
	return [NSURL URLWithString : CMRAppSubjectTextFileName
				  relativeToURL : [self boardURL]];
}
- (NSURL *) boardURL
{
	return [[BoardManager defaultManager] URLForBoardName : 
									[[self BBSSignature] name]];
}
@end



@implementation ThreadsListDownloader(PrivateAccessor)
- (NSURL *) resourceURLForWebBrowser
{
	return [self boardURL];
}
@end



@implementation ThreadsListDownloader(LoadingResourceData)
- (NSString *) subjectsWithData : (NSData *) theData
{
	CMRHostHandler		*handler_;
	CFStringEncoding	enc;
	NSString			*src;
	
	if (nil == theData || 0 == [theData length])
		return nil;
	
	// ONLY FOR DEBUG
	//CMRDebugWriteObject(theData, @"subject.txt");
	
	handler_ = [CMRHostHandler hostHandlerForURL : [self boardURL]];
	if (nil == handler_) return nil;
	
	enc = [handler_ subjectEncoding];
	src = [CMXTextParser stringWithData:theData CFEncoding:enc];
	
	return src;
}
- (void) postDidFinishNotificationWithSubjects : (NSMutableArray *) subjectsList
{
	NSDictionary *userInfo_;
	
	if (nil == subjectsList) return;
	
	userInfo_ = [NSDictionary dictionaryWithObjectsAndKeys : 
							subjectsList,
							CMRDownloaderUserInfoContentsKey,
							[self resourceURL],
							CMRDownloaderUserInfoResourceURLKey,
							[self identifier],
							CMRDownloaderUserInfoIdentifierKey,
							nil];
	UTILNotifyInfo(
		ThreadListDownloaderUpdatedNotification,
		userInfo_);
}



/*** dataProcess:withConnector: ***/
- (BOOL) writeThreadsListWithContents : (NSString *) subjectsText
{
    CMRSubjectReader        *reader_;
    id<CMRSubjectComposer>   composer_;
    
    NSArray      *lines;
    NSEnumerator *lineIter_;
    NSString     *line;
    unsigned int lineNum = 1;
    BOOL         result;

    NSMutableArray *mutableArray = [NSMutableArray array];
    NSMutableSet   *entryIdSet_  = SGTemporarySet();
    
    /*
     *
     * Because subject.txt can be compressed by gzip, it prevents 
     * validation.
     * 
     * In the end, however, we need HTML file for auto-detection.
     *
     */
    if (NO == [[self class] isValideSubjectTXT : subjectsText]) {
        
        static NSCountedSet *sTriedSet;
        NSString *name = [[self BBSSignature] name];
        
        if (nil == sTriedSet) {
            sTriedSet = [[NSCountedSet alloc] initWithCapacity:8];
        }
        if ([sTriedSet countForObject : name] > MAX_TRYDETECT_COUNT) {
            // already MAX_TRYDETECT_COUNT times checked. 
            goto NOT_FOUND;
        }
        [sTriedSet addObject : name];
        
        BoardManager *bm = [BoardManager defaultManager];
        NSURL        *oldURL = [self resourceURL];
        
        if (NO == [bm tryToDetectMovedBoard:name]) {
            goto NOT_FOUND;
        }
        // IMPORTANT:
        // Registered URL may be changed!
        [[CMRNetGrobalLock sharedInstance] remove : oldURL];
        // Notify
        UTILNotifyName(ThreadsListDownloaderShouldRetryUpdateNotification);
        return YES;
        
NOT_FOUND:
        UTILNotifyName(CMRDownloaderNotFoundNotification);
        return NO;
    }
	
	lines = [subjectsText componentsSeparatedByNewline];
	
	if (nil == lines || 0 == [lines count])
		return NO;
	
	lineIter_ = [lines objectEnumerator];
	reader_ = [CMRSubjectReader reader];
	composer_ = [CMRThreadSubjectComposer composerWithBoardName : 
										[[self BBSSignature] name]];
	
	while (line = [lineIter_ nextObject]) {
		id			subject_;
		BOOL		result_;
		NSString	*entryId_;
		
		result_ = [reader_ composeLine : line
							lineNumber : lineNum
						  withComposer : composer_];
		
		if (NO == result_)
			continue;
		
        //
        // Save our life from duplicate entries.
        //
		subject_ = [composer_ getSubject];
		entryId_ = [subject_ stringForKey : ThreadPlistIdentifierKey];
		if (nil == entryId_ || [entryIdSet_ containsObject : entryId_])
			continue;
		
		[entryIdSet_ addObject : entryId_];
		[mutableArray addObject : subject_];
		lineNum++;
	}
	
	[entryIdSet_ removeAllObjects];
	result = [mutableArray writeToFile : [self filePathToWrite] 
							atomically : YES];

	
	if (NO == result) {
		NSString		*title_;
		NSString		*msg_format_;
		NSString		*msg_;
	
		title_ = 
		  NSLocalizedStringFromTable(@"Couldnt_Write_ThreadsList_plist",
		  							 [[AppDefaults class] tableForPanels],
									 nil);
		msg_format_ = 
		  NSLocalizedStringFromTable(@"Reason_Couldnt_Write_ThreadsList_plist",
		  							 [[AppDefaults class] tableForPanels],
									 nil);
		msg_ = [NSString stringWithFormat : msg_format_,
											[self filePathToWrite]];
		[CMRPref runAlertPanelWithLocalizedString : title_
									      message : msg_];
	}
	
	[self postDidFinishNotificationWithSubjects : mutableArray];
	return result;
}
- (BOOL) writeThreadsListData : (NSData *) theData
{
	return [self writeThreadsListWithContents : 
             [self subjectsWithData : SGUtilUngzipIfNeeded(theData)]];
}
- (BOOL) dataProcess : (NSData      *) resourceData
       withConnector : (NSURLHandle *) connector
{
	return [self writeThreadsListData : resourceData];
}
@end



@implementation ThreadsListDownloader(ResourceManagement)
- (BOOL) shouldCancelWithFirstArrivalData : (NSData *) theData
{
    // We also need HTML file for auto-detect moved BBS. 
    return NO;
}
@end



@implementation ThreadsListDownloader(Description)
- (NSString *) resourceName
{
	return CMRAppSubjectTextFileName;
}
@end



