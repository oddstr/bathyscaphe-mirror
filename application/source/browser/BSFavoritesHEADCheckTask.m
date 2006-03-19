/**
  * $Id: BSFavoritesHEADCheckTask.m,v 1.5.2.3 2006/03/19 15:09:53 masakih Exp $
  * BathyScaphe
  *
  * Copyright 2006 BathyScaphe Project. All rights reserved.
  *
  */

#import "BSFavoritesHEADCheckTask.h"
#import "BoardManager.h"
#import "CMRThreadSignature.h"
#import "CMRHostHandler.h"
#import "AppDefaults.h"
#import "CMRThreadAttributes.h"

#define MAX_HEAD_COUNT	30

NSString *const BSFavoritesHEADCheckTaskDidFinishNotification = @"BSFavoritesHEADCheckTaskDidFinishNotification";

static NSString *const BSFavHEADerUAKey	= @"User-Agent";
static NSString *const BSFavHEADerLMKey	= @"Last-Modified";
static NSString *const BSFavCheckMethodKey = @"HEAD";

static NSString	*userAgent_ = nil;
static int modified_ = 0;

static NSString *monazillaUserAgent()
{
	const long	dolibVersion_ = (1 << 16);
		
	// monazilla.org (02.01.20)
	if (userAgent_ == nil) {
		userAgent_ = [[NSString stringWithFormat : @"Monazilla/%d.%02d (%@/%@)",
												   dolibVersion_ >> 16, dolibVersion_ & 0xffff,
												   [NSBundle applicationName], [NSBundle applicationVersion]] retain];
	}
	return userAgent_;
}

static NSURL *getDATURL(NSDictionary *dict)
{
	CMRHostHandler		*handler_;
	NSURL				*boardURL_;
	NSURL				*url_;
	CMRThreadSignature	*tmpSign_;
	
	tmpSign_ = [CMRThreadSignature threadSignatureFromFilepath : [dict objectForKey : CMRThreadLogFilepathKey]];

	boardURL_ = [[BoardManager defaultManager] URLForBoardName : [dict objectForKey : ThreadPlistBoardNameKey]];
	handler_ = [CMRHostHandler hostHandlerForURL : boardURL_];
	
	url_ = [handler_ datURLWithBoard :boardURL_ datName : [tmpSign_ datFilename]];

	return url_;
}

static NSDictionary *replaceAttributesIfNeeded(NSDictionary *thread, NSURL *checkURL)
{
	NSURLResponse	*response = nil;
	NSError			*ifErr = nil;

	//NSURL		*checkURL;
	NSMutableURLRequest	*theRequest;

	/*checkURL = getDATURL(thread);
	if (checkURL == nil) {
		NSLog(@"DAT URL is nil at %@, skipped", [thread objectForKey : CMRThreadTitleKey]);
		return thread;
	}*/

	theRequest = [NSMutableURLRequest requestWithURL : checkURL];
	[theRequest setHTTPMethod : BSFavCheckMethodKey];
	[theRequest setTimeoutInterval : 30.0];
	[theRequest setValue : monazillaUserAgent() forHTTPHeaderField : BSFavHEADerUAKey];

	[NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &ifErr];
	
	if (ifErr) {
		NSLog(@"HEADCheck Error at %@", [thread objectForKey : CMRThreadTitleKey]);
		return thread;
	}

	if([response isKindOfClass : [NSHTTPURLResponse class]]) {
		NSDate			*lastDate_ = [thread objectForKey : CMRThreadModifiedDateKey];
		
		if (lastDate_ == nil) return thread;

		NSDictionary	*dicHead = [(NSHTTPURLResponse *)response allHeaderFields];
		NSString		*sLastMod = [dicHead objectForKey : BSFavHEADerLMKey];
		NSCalendarDate	*dateLastMod = [NSCalendarDate dateWithHTTPTimeRepresentation : sLastMod]; // SGFoundation

		/* dat 落ちしたスレッドの場合、リダイレクトされて http://www.2ch.net/live.html などに飛ばされてしまう。
		   するとリダイレクト先の last-modified と比較することになり、よろしくない。そこで元の URL と response の URL を比較する必要がある。
		   しかも、absoluteURL で比較しないと正しく比較できないので注意。*/
		if([dateLastMod isAfterDate : lastDate_] && [[[response URL] absoluteURL] isEqual: [checkURL absoluteURL]]) {			
			NSMutableDictionary *newThread = [thread mutableCopy];

	        [newThread setObject : [NSNumber numberWithUnsignedInt : ThreadHeadModifiedStatus]
						  forKey : CMRThreadStatusKey];
			
			modified_++;
			return [newThread autorelease];
		}
	}
	return thread;
}


@implementation BSFavoritesHEADCheckTask
+ (id) taskWithFavItemsArray : (NSMutableArray *) loadedList
{
    return [[[self alloc] initWithFavItemsArray : loadedList] autorelease];
}

- (id) initWithFavItemsArray : (NSMutableArray *) loadedList
{
    if (self = [super init]) {
        
        [self setProgress : 0];
        [self setThreadsArray : loadedList];
		[self setAmountString : @"0"];
    }
    return self;
}

- (void) dealloc
{
    [_boardName release];
    [_threadsArray release];
	[_amountString release];
    [super dealloc];
}


- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
    NSDictionary    *userInfo_;
	
    [self checkEachItemOfThreadsArray];
    userInfo_ = [NSDictionary dictionaryWithObjectsAndKeys : [self threadsArray], kBSUserInfoThreadsArrayKey, nil];
    
    [CMRMainMessenger postNotificationName : BSFavoritesHEADCheckTaskDidFinishNotification
                                    object : self
                                  userInfo : userInfo_];
}

- (BOOL) validateThreadBeforeHEADCheck : (NSDictionary *) thread
{
	NSNumber	*status;
	int			t;

	status = [thread objectForKey : CMRThreadStatusKey];
	if(status == nil) return NO;

	if (!([status unsignedIntValue] == ThreadLogCachedStatus)) return NO;
	
	t = [thread integerForKey : CMRThreadNumberOfMessagesKey];
	if (t > 1000) return NO;

	{
		NSString *path_;
		path_ = [CMRThreadAttributes pathFromDictionary : thread];
		if (!path_) return NO;
		
		NSDictionary	*tmp_;
		id		rep_;
		CMRThreadUserStatus	*s;

		tmp_ = [NSDictionary dictionaryWithContentsOfFile : path_];
		rep_ = [tmp_ objectForKey : CMRThreadUserStatusKey];
		s = [CMRThreadUserStatus objectWithPropertyListRepresentation : rep_];
		if((s != nil) && [s isDatOchiThread]) return NO;
	}

	return YES;
}

- (void) checkEachItemOfThreadsArray
{
    NSEnumerator        *iter;
    NSMutableDictionary *thread_;
	NSString			*soundName_;
	NSSound				*finishedSound_ = nil;
    
    unsigned nEnded_ = 0;
    unsigned nElem_  = [[self threadsArray] count];
	unsigned nActuallyEnded_ = 0;

    UTILAssertNotNilArgument([self threadsArray], @"Threads List Array");
	
	modified_ = 0;
	
	NSAutoreleasePool	*pool_ = [[NSAutoreleasePool alloc] init];
	NSMutableArray		*newArray_ = [[NSMutableArray alloc] initWithCapacity : nElem_];

    iter = [[self threadsArray] objectEnumerator];
    while (thread_ = [iter nextObject]) {
		
		[self checkIsInterrupted]; // ユーザが中止できるように


		if((nActuallyEnded_ < MAX_HEAD_COUNT) && [self validateThreadBeforeHEADCheck : thread_]) {
			NSURL	*datURL = getDATURL(thread_);
			if (datURL != nil) {
				NSDictionary *newItem;
				newItem = replaceAttributesIfNeeded(thread_, datURL);
				[newArray_ addObject : newItem];
				
				nActuallyEnded_++;
			} else {
				[newArray_ addObject : thread_];
			}
		} else {
			[newArray_ addObject : thread_];
		}

        nEnded_++;
        [self setProgress : (((double)nEnded_ / (double)nElem_) * 100)];
		[self setAmountString : [NSString stringWithFormat : @"%i/%i (%i)",nEnded_,nElem_,nActuallyEnded_]];
    }

	soundName_ = [CMRPref HEADCheckNewArrivedSound];
	if ((modified_ > 0) && ![soundName_ isEqualToString : @""]) {
		finishedSound_ = [NSSound soundNamed :soundName_];
	} else {
		soundName_ = [CMRPref HEADCheckNoUpdateSound];
		if (![soundName_ isEqualToString : @""])
			finishedSound_ = [NSSound soundNamed : soundName_];
	}
	[self setThreadsArray : newArray_];
	[newArray_ release];

	if(finishedSound_)
		[finishedSound_ play];

	[CMRPref setLastHEADCheckedDate : [NSDate date]];
	
	double interval_ = (double)nActuallyEnded_ * 20.0;
	[CMRPref setHEADCheckTimeInterval : ((interval_ < 300.0) ? 300.0 : interval_)];

	[pool_ release];
}

- (NSString *) boardName
{
    return _boardName;
}

- (void) setBoardName : (NSString *) aBoardName
{
    id        tmp;
    
    tmp = _boardName;
    _boardName = [aBoardName retain];
    [tmp release];
}

- (NSMutableArray *) threadsArray
{
    return _threadsArray;
}
- (void) setThreadsArray : (NSMutableArray *) aThreadsArray
{
    id        tmp;
    
    tmp = _threadsArray;
    _threadsArray = [aThreadsArray retain];
    [tmp release];
}

// CMRTask:
- (NSString *) title
{
    NSString        *format_;
    NSString        *name_;
    
    name_ = [self boardName];
    format_ = [self localizedString : @"Checking Favorites Title"];
    
    return [NSString stringWithFormat : 
                        format_ ? format_ : @"%@",
                        name_ ? name_ : @""];
}

- (NSString *) messageInProgress
{
    NSString        *format_;
    NSString        *title_;
    
    title_ = [self title];
    format_ = [self localizedString : @"Checking Favorites Message"];
    
    return [NSString stringWithFormat : 
                        format_ ? format_ : @"%@ (%@)",
                        title_ ? title_ : @"",
						[self amountString]];
}

- (unsigned) progress
{
    return _progress;
}

- (void) setProgress : (unsigned) newValue
{
    _progress = newValue;
}

- (double) amount
{
    if ([self progress] <= 0)
        return -1;
    
    return [self progress];
}

- (NSString *) amountString
{
	return _amountString;
}

- (void) setAmountString : (NSString *) someString
{
    id        tmp;
    
    tmp = _amountString;
    _amountString = [someString retain];
    [tmp release];
}
@end
