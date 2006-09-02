/**
 * $Id: BoardManager.m,v 1.6.2.3 2006/09/02 14:30:12 tsawada2 Exp $
 * 
 * BoardManager.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#import "BoardManager_p.h"
#import "CMRDocumentFileManager.h"

// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"


static id kDefaultManager;

@implementation BoardManager
+ (id) defaultManager
{
    /*
    FROM COMONA'S SOURCE COMMENT
    
    2004-05-08 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
    ---------------------------------------------------------
    In Comona, at starting write this, I decided that NEVER
    USE "double-checking idiom", because it is NOT perfect.
    Instead of that, simply pre-instanciate all singleton 
    objects before application startup, be multi-threaded.
    
    NOTE: 
    But, CMNAppGlobal itself is instanciate by NSApplicationMain(),
    (see an instance in MainMenu.nib), it's OK.
    */
    if (nil == kDefaultManager) {
        kDefaultManager = [[self alloc] init];
    }
    return kDefaultManager;
}
- (id) init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter]
                 addObserver : self
                    selector : @selector(applicationWillTerminate:)
                        name : NSApplicationWillTerminateNotification
                      object : NSApp];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver : self];
    
    [_defaultList release];
    [_userList release];
	[_noNameDict release];
    [super dealloc];
}

- (NSString *) userBoardListPath
{
	NSString	*filepath_;
	
	filepath_ = [[CMRFileManager defaultManager] dataRootDirectoryPath];
	return [filepath_ stringByAppendingPathComponent : CMRUserBoardFile];
}
- (NSString *) defaultBoardListPath
{
	NSString	*filepath_;
	
	filepath_ = [[CMRFileManager defaultManager] dataRootDirectoryPath];
	return [filepath_ stringByAppendingPathComponent : CMRDefaultBoardFile];
}
- (NSString *) spareDefaultBoardListPath
{
	NSString	*filepath_;

	filepath_ = [[NSBundle mainBundle] pathForResource : @"board_default" ofType : @"plist"];
	return filepath_;
}

+ (NSString *) NNDFilepath
{
	return [[CMRFileManager defaultManager]
				 supportFilepathWithName : @"BoardProperties.plist"
						resolvingFileRef : NULL];
}

+ (NSString *) oldNNDFilepath
{
	return [[CMRFileManager defaultManager]
				 supportFilepathWithName : CMRNoNamesFile
						resolvingFileRef : NULL];
}

- (BoardList *) makeBoardList : (Class     ) aClass
           withContentsOfFile : (NSString *) aFile
{
    BoardList *list;
    
    list = [[aClass alloc] initWithContentsOfFile : aFile];
    [[NSNotificationCenter defaultCenter]
            addObserver : self
               selector : @selector(boardListDidChange:)
                   name : CMRBBSListDidChangeNotification
                 object : list];
    
    return list;
}
- (BoardList *) defaultList
{
    if (nil == _defaultList) {
		NSFileManager	*dfm;
		NSString		*dListPath;
		dfm = [NSFileManager defaultManager];
		dListPath = [self defaultBoardListPath];

		if (![dfm fileExistsAtPath : dListPath]) {
			//NSLog(@"defaultList.plist not found, so we copy one from our own Resources directory.");
			[dfm copyPath : [self spareDefaultBoardListPath] toPath : dListPath handler : nil];
		}
        _defaultList = 
          [self makeBoardList : [BoardList class]
           withContentsOfFile : dListPath];
    }
    return _defaultList;
}
- (BoardList *) userList
{
    if (nil == _userList) {
        _userList = 
          [self makeBoardList : [FavoritesList class]
           withContentsOfFile : [self userBoardListPath]];
    }
    return _userList;
}

#pragma mark -
#pragma mark CometBlaster Addition
- (BOOL) copyMatchedItem : (NSString *) keyword
				   items : (NSArray  *) items
				  toList : (BoardList *) filteredList
{
    int i;
    BOOL found = NO;

    for (i = 0; i < [items count]; i++) {
        NSDictionary	*root = [items objectAtIndex : i];
        NSRange			range;

        range = [[root objectForKey : BoardPlistNameKey] rangeOfString : keyword
															   options : NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
			[filteredList addItem: root afterObject: nil];
            found |= YES;
        } else {
            found |= NO;
        }
        
        if (![self copyMatchedItem : keyword
							 items : [root objectForKey : BoardPlistContentsKey]
							toList : filteredList]) {
			continue;
        }
    }
    return found;
}

- (BoardList *) filteredListWithString: (NSString *) keyword
{
	BoardList *result_ = [[BoardList alloc] init];

    [self copyMatchedItem : keyword
					items : [[self defaultList] boardItems]
				   toList : result_];

	return [result_ autorelease];
}
#pragma mark -
- (NSURL *) URLForBoardName : (NSString *) boardName
{
	NSURL	*url_;
	
	if (nil == boardName) return nil;
	url_ = [[self userList] URLForBoardName : boardName];
	return url_ ? url_ : [[self defaultList] URLForBoardName : boardName];
}
- (NSString *) boardNameForURL : (NSURL *) theURL
{
	NSString	*name_;
	
	if (nil == theURL) return nil;
	name_ = [[self userList] boardNameForURL : theURL];
	return name_ ? name_ : [[self defaultList] boardNameForURL : theURL];
}

- (void) updateURL : (NSURL    *) anURL
      forBoardName : (NSString *) aName
{
    [[self userList] updateURL:anURL forBoardName:aName];
    [[self defaultList] updateURL:anURL forBoardName:aName];
}

#pragma mark detect moved BBS
- (BOOL) movedBoardWasFound : (NSString *) boardName
                newLocation : (NSURL    *) anNewURL
                oldLocation : (NSURL    *) anOldURL
{
    int ret;
	
	NSAlert *alert_ = [[NSAlert alloc] init];
	[alert_ setAlertStyle : NSInformationalAlertStyle];
	[alert_ setMessageText : NSLocalizedString(@"MovedBBSFoundTitle", nil)];
	[alert_ setInformativeText : [NSString stringWithFormat : NSLocalizedString(@"MovedBBSFoundFormat", nil),
															  boardName, [anOldURL absoluteString], [anNewURL absoluteString]]];
	[alert_ addButtonWithTitle : NSLocalizedString(@"MovedOK", nil)];
	[alert_ addButtonWithTitle : NSLocalizedString(@"MovedCancel", nil)];
	[alert_ setHelpAnchor : NSLocalizedString(@"MovedBBSHelpAnchor", nil)];
	[alert_ setShowsHelp : YES];
	
    ret = [alert_ runModal];
	[alert_ release];

	if (ret != NSAlertFirstButtonReturn) {
        return NO;
    }
    [self updateURL : anNewURL forBoardName : boardName];
    
    return YES;
}
- (BOOL) detectMovedBoardWithResponseHTML : (NSString *) htmlContents
                                boardName : (NSString *) boardName
{
    id<XmlPullParser> xpp;
    
    int       type;
    NSURL    *oldURL = [self URLForBoardName : boardName];
    NSString *origDir = [[oldURL path] lastPathComponent];
    NSURL    *newURL = nil;
    
    UTIL_DEBUG_WRITE2(@"Name:%@ Old:%@", boardName, [oldURL stringValue]);
    UTIL_DEBUG_WRITE1(@"HTML response was:\n"
    @"----------------------------------------\n"
    @"%@", htmlContents);
    if (nil == oldURL || nil == origDir) {
        return NO;
    }
    
    xpp = [[[SGXmlPullParser alloc] initHTMLParser] autorelease];
    [xpp setInputSource : htmlContents];
    
    // Setting up features
    [xpp setFeature:NO forKey:SGXmlPullParserDisableEntityResolving];
    
    type = [xpp nextName : @"html" 
                     type : XMLPULL_START_TAG
                  options : NSCaseInsensitiveSearch];
    while ((type = [xpp next]) != XMLPULL_END_DOCUMENT) {
        if ( XMLPULL_START_TAG == [xpp eventType] &&
             NSOrderedSame == [[xpp name] caseInsensitiveCompare:@"a"])
        {
            NSString *dir;
            NSString *href = [xpp attributeForName:@"href"];

            dir = [href lastPathComponent];
            UTIL_DEBUG_WRITE2(@"  href=%@ dir=%@", href, dir);
            if (NO == [dir isEqualToString : origDir]) {
                continue;
            }
            href = [[href copy] autorelease];
            newURL = [NSURL URLWithString : href];
        }
    }
    
    if (newURL != nil) {
        if ([[newURL host] isEqualToString : [oldURL host]]) {
            return NO;
        }
        return [self movedBoardWasFound : boardName
                            newLocation : newURL
                            oldLocation : oldURL];
    }
    return NO;
}
- (BOOL) tryToDetectMovedBoard : (NSString *) boardName
{
    NSURL  *URL = [self URLForBoardName : boardName];
	NSURLRequest	*req_;
	BOOL	canHandle_;
    NSURLResponse	*response;
	NSError	*error;
    NSData *data;
    NSString *contents;

    // We can do nothing.
    if (nil == URL) return nil;
	
    NSLog(@"BathyScaphe try to detect moved BBS:%@ URL:%@", boardName, [URL absoluteString]);
    
	req_ = [NSURLRequest requestWithURL : URL];
	canHandle_ = [NSURLConnection canHandleRequest : req_];
	//NSLog(@"CanHandleRequest Check - %@", canHandle_ ? @"OK" : @"NO");
	if (!canHandle_) return NO;

	data = [NSURLConnection sendSynchronousRequest : req_ returningResponse : &response error : &error];

    if (nil == data) {
		NSLog(@"Error: %@", [error localizedDescription]);
		return NO;
	}

    //CMRDebugWriteObject(data, @"debug2.txt");
    if (NULL == nsr_strncasestr((const char*)([data bytes]), "<html", [data length])) {
		return NO;
	}
    
    contents = [NSString stringWithData:data encoding:NSShiftJISStringEncoding];
	    
    return [self detectMovedBoardWithResponseHTML:contents boardName:boardName];
}
@end



@implementation BoardManager(Notification)
- (void) boardListDidChange : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		CMRBBSListDidChangeNotification);
	UTILAssertKindOfClass([notification object], BoardList);
	
	[[NSNotificationCenter defaultCenter]
			 postNotificationName : ([notification object] == [self defaultList])
			 			? CMRBBSManagerDefaultListDidChangeNotification
						: CMRBBSManagerUserListDidChangeNotification
					       object : self];
    
    [self saveListsIfNeed];
}

- (BOOL) saveNoNameDict
{
	NSString *errorStr = nil;
	NSMutableDictionary	*noNameDict_ = [self noNameDict];
	NSData *binaryData_ = [NSPropertyListSerialization dataFromPropertyList: noNameDict_
																	 format: NSPropertyListBinaryFormat_v1_0
														   errorDescription: &errorStr];

	if (!binaryData_) {
		NSLog(@"BoardManager failed to serialize noNameDict using NSPropertyListSerialization.");
		//NSLog(errorStr);
		//[errorStr release];
		return [noNameDict_ writeToFile: [[self class] NNDFilepath] atomically: YES];
	}
	
	return [binaryData_ writeToFile: [[self class] NNDFilepath] atomically: YES];
}

- (void) applicationWillTerminate : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		NSApplicationWillTerminateNotification);
	UTILAssertNotificationObject(
		notification,
		NSApp);
	
	[self saveListsIfNeed];

	// NoNames.plist ‚Íí‚É•Û‘¶
	[self saveNoNameDict];
}

- (BOOL) saveListsIfNeed
{	
	if ([[self userList] isEdited]) {
		[[self userList] writeToFile : 
			[self userBoardListPath]
						atomically : YES];
		[[self userList] setIsEdited : NO];
	}
	if ([[self defaultList] isEdited]) {
		[[self defaultList] writeToFile : 
			[self defaultBoardListPath]
						atomically : YES];
		[[self defaultList] setIsEdited : NO];
	}
	return YES;
}
@end