/**
 * $Id: ThreadsListDownloader.m,v 1.3.2.1 2005/12/14 16:05:06 masakih Exp $
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
#import "CMRThreadSubjectComposer.h"
#import "CMRDocumentFileManager.h"

#import "CMRSubjectReader.h"
#import "CMRHostHandler.h"


// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"

NSString *const ThreadListDownloaderUpdatedNotification = @"ThreadListDownloaderUpdatedNotification";
NSString *const ThreadsListDownloaderShouldRetryUpdateNotification = @"ThreadsListDownloaderShouldRetryUpdateNotification";


// detect moved bbs address x times.
#define MAX_TRYDETECT_COUNT    2



@implementation ThreadsListDownloader
+ (id) threadsListDownloaderWithBBSName : (NSString *) boardName
{
	return [[[self alloc] initWithBBSName : boardName] autorelease];
}

- (id) initWithBBSName : (NSString *) boardName
{
	NSURL	*boardURL_;
	
	boardURL_ = [[BoardManager defaultManager] URLForBoardName : boardName];
	if (NO == [[self class] canInitWithURL : boardURL_]) {
		[self autorelease];
		return nil;
	}
	
	if (self = [super init]) {
		// 単純に boardName を identifier にすると、ThreadsListUpdateTask のそれと重複し、TaskManager が混乱する
		[self setIdentifier : [NSDictionary dictionaryWithObject : boardName forKey :  @"ThreadsListDownLoaderIdentifier"]];
	}
	return self;
}


+ (BOOL) canInitWithURL : (NSURL *) url
{
	return ([CMRHostHandler hostHandlerForURL : url] != nil);
}
/*
+ (BOOL) isValideSubjectTXT : (NSString *) contents
{
	NSRange found;
	
	found = [contents rangeOfString : @"<HTML"
							options : NSCaseInsensitiveSearch]; 
	
	return (found.location == NSNotFound);
}
*/
- (NSString *) BBSName
{
	return [[self identifier] objectForKey : @"ThreadsListDownLoaderIdentifier"];
}
- (void) setBBSName : (NSString *) aBBSName
{
	NSLog(@"WARNING : ThreadsListDownloader setBBSName: KORE YOBARETARA YABAI. please report.");
	[self setIdentifier : aBBSName];
}

@end



@implementation ThreadsListDownloader(Accessor)
- (NSString *) filePathToWrite
{
	return [[CMRDocumentFileManager defaultManager] threadsListPathWithBoardName : [self BBSName]];
}
- (NSURL *) resourceURL
{
	return [NSURL URLWithString : CMRAppSubjectTextFileName
				  relativeToURL : [self boardURL]];
}
- (NSURL *) boardURL
{
	return [[BoardManager defaultManager] URLForBoardName : [self BBSName]];
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
							[self BBSName],
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
	
	NSRange		 validationCheck;

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
	validationCheck = [subjectsText rangeOfString : @"<HTML"
										  options : NSCaseInsensitiveSearch]; 
	if (validationCheck.location != NSNotFound) {
    //if (NO == [[self class] isValideSubjectTXT : subjectsText]) {
        
        static NSCountedSet *sTriedSet;
        NSString *name = [self BBSName];
        
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
	composer_ = [CMRThreadSubjectComposer composerWithBoardName : [self BBSName]];
	
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
