/**
  * $Id: BSFavoritesHEADCheckTask.m,v 1.1 2006/01/21 07:17:02 tsawada2 Exp $
  * BathyScaphe
  *
  * Copyright 2006 BathyScaphe Project. All rights reserved.
  *
  */

#import "BSFavoritesHEADCheckTask.h"
#import "BoardManager.h"
#import "CMRThreadSignature.h"
#import "CMRHostHandler.h"

NSString *const BSFavoritesHEADCheckTaskDidFinishNotification = @"BSFavoritesHEADCheckTaskDidFinishNotification";


@implementation BSFavoritesHEADCheckTask
- (NSURL *) getDATURL: (NSDictionary        *)dict
{
	CMRHostHandler	*handler_;
	NSURL *url_;
	CMRThreadSignature	*tmptmp = [CMRThreadSignature threadSignatureFromFilepath : [dict objectForKey : @"Path"]];
	//if(tmptmp)NSLog(@"%@",[tmptmp datFilename]);
	NSURL *boardURL_ = [[BoardManager defaultManager] URLForBoardName : [dict objectForKey : @"BoardName"]];
	//NSLog(@"%@",[boardURL_ description]);
	handler_ = [CMRHostHandler hostHandlerForURL : boardURL_];
	url_ = [handler_ datURLWithBoard:boardURL_ datName:[tmptmp datFilename]];
	//NSString *mmm_ = [NSString stringWithFormat : @"%@dat/%@", [boardURL_ absoluteString],[tmptmp datFilename]];
	//NSLog(@"%@",mmm_);
	//NSLog(@"%@",[url_ absoluteString]);
	return url_;//[NSURL URLWithString : mmm_];
}

- (NSDictionary *) constructByAppendingCachedInfo : (NSDictionary *)thread withURL : (NSURL *) anURL
{
	NSURLResponse *response = nil;
	NSError *ifErr = nil;
	
	unsigned s;
	NSNumber *status;
	status = [thread objectForKey : CMRThreadStatusKey];
	if(status == nil) return thread;
	s = [status unsignedIntValue];
	if (!(s == ThreadLogCachedStatus)) {

		return thread;
	}

	if (anURL == nil) return thread;

	NSMutableURLRequest	*theRequest = [NSMutableURLRequest requestWithURL : anURL];
	[theRequest setHTTPMethod : @"HEAD"];
	[theRequest setTimeoutInterval : 30.0];
	[theRequest setValue : @"Monazilla/1.00 (BathyScaphe/143)" forHTTPHeaderField : @"User-Agent"];

	[NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &ifErr];
	
	if (ifErr) {
		NSLog(@"HEADCHeck Error");
		return thread;
	}

	if([response isKindOfClass : [NSHTTPURLResponse class]]) {
		NSDate			*lastDate_;
		NSDictionary *dicHead = [(NSHTTPURLResponse *)response allHeaderFields];

		NSString	*sLastMod = [dicHead objectForKey : @"Last-Modified"];
		NSCalendarDate	*dateLastMod = [NSCalendarDate dateWithString : sLastMod 
													   calendarFormat : @"%a, %d %b %Y %H:%M:%S %Z"];
		
		lastDate_ = [thread objectForKey : CMRThreadModifiedDateKey];

		if([dateLastMod isAfterDate : lastDate_] && [[[response URL] absoluteString] isEqualToString : [anURL absoluteString]]) {			
			NSMutableDictionary *thread2 = [thread mutableCopy];
			/* thread の status を更新 */
	        [thread2 setObject : [NSNumber numberWithUnsignedInt : ThreadHeadModifiedStatus]
					   forKey : CMRThreadStatusKey];
			return [thread2 autorelease];
		}
	}
	return thread;
}

+ (id) taskWithFavItemsArray : (NSMutableArray      *) loadedList
{
    return [[[self alloc] initWithFavItemsArray : loadedList] autorelease];
}

- (id) initWithFavItemsArray : (NSMutableArray      *) loadedList
{
    if (self = [super init]) {
        
        [self setProgress : 0];
        [self setThreadsArray : loadedList];
    }
    return self;
}

- (void) dealloc
{
    [_boardName release];
    [_threadsArray release];
    [super dealloc];
}


- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
    NSDictionary    *userInfo_;

    [self checkEachItemOfFavItemsArray];
    userInfo_ = [NSDictionary dictionaryWithObjectsAndKeys :
                    [self threadsArray],   kBSUserInfoThreadsArrayKey, 
                    nil];
    
    [CMRMainMessenger postNotificationName : BSFavoritesHEADCheckTaskDidFinishNotification
                                    object : self
                                  userInfo : userInfo_];
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
                        format_ ? format_ : @"%@",
                        title_ ? title_ : @""];
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
- (void) checkEachItemOfFavItemsArray
{
    NSEnumerator        *iter;
    NSMutableDictionary *thread_;
    
    unsigned nEnded_ = 0;
    unsigned nElem_  = [[self threadsArray] count];

    UTILAssertNotNilArgument([self threadsArray], @"Threads List Array");
	
	NSAutoreleasePool	*pool_ = [[NSAutoreleasePool alloc] init];
	NSMutableArray		*newArray_ = [[NSMutableArray alloc] initWithCapacity : [[self threadsArray] count]];

    iter = [[self threadsArray] objectEnumerator];
    while (thread_ = [iter nextObject]) {
        NSDictionary *newItem;
		NSURL *tmpURL_;
		
		[self checkIsInterrupted]; // ユーザが中止できるように

		tmpURL_ = [self getDATURL : thread_];
        newItem = [self constructByAppendingCachedInfo: thread_ withURL : tmpURL_];
		[newArray_ addObject : newItem];

        nEnded_++;
        [self setProgress : (((double)nEnded_ / (double)nElem_) * 100)];
    }

	[self setThreadsArray : newArray_];
	[newArray_ release];
	[pool_ release];
}
@end
