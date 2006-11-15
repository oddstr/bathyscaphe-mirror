/**
  * $Id: BSFavoritesHEADCheckTask.m,v 1.8.2.3 2006/11/15 02:01:06 tsawada2 Exp $
  * BathyScaphe
  *
  * Copyright 2006 BathyScaphe Project. All rights reserved.
  *
  */

#import "BSFavoritesHEADCheckTask.h"
#import "BoardManager.h"
#import "CMRHostHandler.h"
#import "AppDefaults.h"
#import "CMRThreadAttributes.h"

NSString *const BSFavoritesHEADCheckTaskDidFinishNotification = @"BSFavoritesHEADCheckTaskDidFinishNotification";

static NSString *const BSFavHEADerUAKey	= @"User-Agent";
static NSString *const BSFavHEADerLMKey	= @"Last-Modified";
static NSString *const BSFavCheckMethodKey = @"HEAD";

// CMRTaskDescription.strings
static NSString *const BSFavLoStrTitleKey = @"Checking Favorites Title";
static NSString *const BSFavLoStrMsgKey = @"Checking Favorites Message";
static NSString *const BSFavLoStrStatusKey = @"Checking Favorites Status";

static NSString	*userAgent_ = nil;
static int modified_ = 0;

static NSURL *getDATURL(NSDictionary *dict)
{
	NSString	*datName_;
	CMRHostHandler		*handler_;
	NSURL				*boardURL_;
	NSURL				*url_;
	
	datName_ = [[dict objectForKey: ThreadPlistIdentifierKey] stringByAppendingPathExtension: @"dat"];

	boardURL_ = [[BoardManager defaultManager] URLForBoardName: [dict objectForKey: ThreadPlistBoardNameKey]];
	handler_ = [CMRHostHandler hostHandlerForURL: boardURL_];

	url_ = [handler_ datURLWithBoard: boardURL_ datName: datName_];

	return url_;
}

@implementation BSFavoritesHEADCheckTask
- (NSMutableURLRequest *) setupURLRequestForURL: (NSURL *) url
{
	NSMutableURLRequest	*theRequest;

	theRequest = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];

	[theRequest setHTTPMethod: BSFavCheckMethodKey];
	[theRequest setValue: userAgent_ forHTTPHeaderField: BSFavHEADerUAKey];
	
	return theRequest;
}

- (NSDictionary *) modifiedAttributesIfNeededForThread: (NSDictionary *) thread datURL: (NSURL *) checkURL
{
	NSURLResponse	*response = nil;
	NSError			*ifErr = nil;

	NSMutableURLRequest	*theRequest = [self setupURLRequestForURL: checkURL];

	[NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &ifErr];
	
	if (ifErr) {
		NSLog(@"HEADCheck Error at %@", [thread objectForKey: CMRThreadTitleKey]);
		return thread;
	}

	if([response isKindOfClass : [NSHTTPURLResponse class]]) {
		NSDate			*lastDate_ = [thread objectForKey : CMRThreadModifiedDateKey];
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

+ (id) taskWithFavItemsArray : (NSMutableArray *) loadedList
{
    return [[[self alloc] initWithFavItemsArray : loadedList] autorelease];
}

- (id) initWithFavItemsArray : (NSMutableArray *) loadedList
{
    if (self = [super init]) {
		userAgent_ = [[NSBundle monazillaUserAgent] retain];        
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

- (NSURL *) validateThreadBeforeHEADCheck: (NSDictionary *) thread
{
	NSNumber	*status;
	int			t;

	status = [thread objectForKey : CMRThreadStatusKey];
	if(status == nil) return nil;

	if (!([status unsignedIntValue] == ThreadLogCachedStatus)) return nil;

	if (![thread objectForKey : CMRThreadModifiedDateKey]) return nil;
	
	t = [thread integerForKey : CMRThreadNumberOfMessagesKey];
	if (t > 1000) return nil;

	{
		NSString *path_;
		path_ = [CMRThreadAttributes pathFromDictionary : thread];
		if (!path_) return nil;
		
		NSDictionary	*tmp_;
		id		rep_;
		CMRThreadUserStatus	*s;

		tmp_ = [NSDictionary dictionaryWithContentsOfFile : path_];
		rep_ = [tmp_ objectForKey : CMRThreadUserStatusKey];
		s = [CMRThreadUserStatus objectWithPropertyListRepresentation : rep_];
		if((s != nil) && [s isDatOchiThread]) return nil;
	}

	return getDATURL(thread);
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
	unsigned nDidntCheck_ = 0;

    UTILAssertNotNilArgument([self threadsArray], @"Threads List Array");
	
	modified_ = 0;
	
	NSAutoreleasePool	*pool_ = [[NSAutoreleasePool alloc] init];
	NSMutableArray		*newArray_ = [[NSMutableArray alloc] initWithCapacity : nElem_];

    iter = [[self threadsArray] objectEnumerator];
    while (thread_ = [iter nextObject]) {
		NSURL *datURL = nil;
		[self checkIsInterrupted]; // ユーザが中止できるように

		if((datURL = [self validateThreadBeforeHEADCheck: thread_]) != nil) {
			NSDictionary *newItem;
			newItem = [self modifiedAttributesIfNeededForThread: thread_ datURL: datURL];
			[newArray_ addObject : newItem];
			
			nActuallyEnded_++;
		} else {
			nDidntCheck_++;
			[newArray_ addObject : thread_];
		}

        nEnded_++;
        [self setProgress : (((double)nEnded_ / (double)nElem_) * 100)];
		[self setAmountString : [NSString stringWithFormat: [self localizedString: BSFavLoStrStatusKey], nEnded_, nElem_, nDidntCheck_]];
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
    format_ = [self localizedString : BSFavLoStrTitleKey];
    
    return [NSString stringWithFormat : 
                        format_ ? format_ : @"%@",
                        name_ ? name_ : @""];
}

- (NSString *) messageInProgress
{
    NSString        *format_;
    NSString        *title_;
    
    title_ = [self title];
    format_ = [self localizedString : BSFavLoStrMsgKey];
    
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
