//
//  BoardManager.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/08.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BoardManager_p.h"
#import "CMRDocumentFileManager.h"
#import "BSBoardInfoInspector.h"
#import "DatabaseManager.h"
#import <CocoMonar/CMRSingletonObject.h>

// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"


@implementation BoardManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

- (id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(applicationWillTerminate:)
													 name:NSApplicationWillTerminateNotification
												   object:NSApp];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[m_localRulesPanelControllers release];
    [_defaultList release];
    [_userList release];
	[_noNameDict release];
    [super dealloc];
}

- (NSString *)userBoardListPath
{
	NSString	*filepath_;
	
	filepath_ = [[CMRFileManager defaultManager] dataRootDirectoryPath];
	return [filepath_ stringByAppendingPathComponent:CMRUserBoardFile];
}

- (NSString *)defaultBoardListPath
{
	NSString	*filepath_;
	
	filepath_ = [[CMRFileManager defaultManager] dataRootDirectoryPath];
	return [filepath_ stringByAppendingPathComponent:CMRDefaultBoardFile];
}

+ (NSString *)spareDefaultBoardListPath
{
	return [[NSBundle mainBundle] pathForResource:@"board_default" ofType:@"plist"];
}

+ (NSString *)NNDFilepath
{
	return [[CMRFileManager defaultManager] supportFilepathWithName:BSBoardPropertiesFile resolvingFileRef:NULL];
}

+ (NSString *)oldNNDFilepath
{
	return [[CMRFileManager defaultManager] supportFilepathWithName:CMRNoNamesFile resolvingFileRef:NULL];
}

- (SmartBoardList *)makeBoardList:(Class)aClass withContentsOfFile:(NSString *)aFile
{
    SmartBoardList *list;
    
    list = [[aClass alloc] initWithContentsOfFile:aFile];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(boardListDidChange:)
												 name:CMRBBSListDidChangeNotification
											   object:list];

    return list;
}

// このへん、暫定
- (SmartBoardList *)defaultList:(BOOL)flag
{
    if (flag && !_defaultList) {
		NSFileManager	*dfm;
		NSString		*dListPath;
		dfm = [NSFileManager defaultManager];
		dListPath = [self defaultBoardListPath];
		
		if (![dfm fileExistsAtPath:dListPath]) {
			[dfm copyPath:[[self class] spareDefaultBoardListPath] toPath:dListPath handler:nil];
		}
        _defaultList = [self makeBoardList:[SmartBoardList class] withContentsOfFile:dListPath];
    }
    return _defaultList;
}

- (SmartBoardList *)defaultList
{
	return [self defaultList:YES];
}

- (SmartBoardList *)defaultListWithoutNeedingInitialize
{
	return [self defaultList:NO];
}

- (SmartBoardList *)userList
{
    if (!_userList) {
        _userList = [self makeBoardList:[SmartBoardList class] withContentsOfFile:[self userBoardListPath]];
    }
    return _userList;
}

#pragma mark Filtering List
- (BOOL)copyMatchedItem:(NSString *)keyword items:(NSArray *)items toList:(SmartBoardList *)filteredList
{
    int i;
    BOOL found = NO;

    for (i = 0; i < [items count]; i++) {
        BoardListItem	*root = [items objectAtIndex:i];
        NSRange			range;
		
        range = [[root representName] rangeOfString:keyword options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
			[filteredList addItem:root afterObject:nil];
            found |= YES;
        } else {
            found |= NO;
        }

        if ([root numberOfItem] != 0 && ![self copyMatchedItem:keyword items:[root items] toList:filteredList]) {
			continue;
        }
    }
    return found;
}

- (SmartBoardList *)filteredListWithString:(NSString *)keyword
{
	SmartBoardList *result_ = [[SmartBoardList alloc] init];

    [self copyMatchedItem:keyword items:[[self defaultList] boardItems] toList:result_];

	return [result_ autorelease];
}

#pragma mark Board Name <--> URL
- (NSURL *)URLForBoardName:(NSString *)boardName
{
	NSURL	*url_ = nil;
	NSString *urlString;
	DatabaseManager *dbm = [DatabaseManager defaultManager];
	NSArray *ids;
	
	ids = [dbm boardIDsForName:boardName];
	/* TODO 複数の場合の処理 */
	urlString = [dbm urlStringForBoardID:[[ids objectAtIndex:0] unsignedIntValue]];
	if (urlString) {
		url_ = [NSURL URLWithString:urlString];
	}
	
	return url_;
}

- (NSString *)boardNameForURL:(NSURL *)theURL
{
	NSString	*name_;
	DatabaseManager *dbm = [DatabaseManager defaultManager];
	unsigned boardID;
	
	boardID = [dbm boardIDForURLString:[theURL absoluteString]];
	name_ = [dbm nameForBoardID:boardID];
	
	return name_;
}

- (void)updateURL:(NSURL *)anURL forBoardName:(NSString *)aName
{
/*	DatabaseManager *dbm = [DatabaseManager defaultManager];
	NSArray *ids;
	unsigned boardID;
	
	ids = [dbm boardIDsForName:aName];
	// TODO 複数の場合の処理
	boardID = [[ids objectAtIndex:0] unsignedIntValue];
	[dbm moveBoardID:boardID toURLString:[anURL absoluteString]];
	[[self userList] setIsEdited:YES];*/
	id item = [self itemForName:aName];
//	if (!item) return;
	NSString	*newURLString = [anURL absoluteString];
//	[[self defaultList] setURL:newURLString toItem:item];
//	[[self userList] setURL:newURLString toItem:item];
	[self editBoardItem:item newURLString:newURLString];
}

#pragma mark detect moved BBS
- (BOOL)movedBoardWasFound:(NSString *)boardName newLocation:(NSURL *)anNewURL oldLocation:(NSURL *)anOldURL
{
	NSAlert *alert_ = [[[NSAlert alloc] init] autorelease];
	[alert_ setAlertStyle:NSInformationalAlertStyle];
	[alert_ setMessageText:NSLocalizedString(@"MovedBBSFoundTitle", nil)];
	[alert_ setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"MovedBBSFoundFormat", nil),
															  boardName, [anOldURL absoluteString], [anNewURL absoluteString]]];
	[alert_ addButtonWithTitle:NSLocalizedString(@"MovedOK", nil)];
	[alert_ addButtonWithTitle:NSLocalizedString(@"MovedCancel", nil)];
	[alert_ setHelpAnchor:NSLocalizedString(@"MovedBBSHelpAnchor", nil)];
	[alert_ setShowsHelp:YES];

	if ([alert_ runModal] != NSAlertFirstButtonReturn) {
        return NO;
    }
    [self updateURL:anNewURL forBoardName:boardName];

    return YES;
}

- (BOOL)detectMovedBoardWithResponseHTML:(NSString *)htmlContents boardName:(NSString *)boardName
{
    id<XmlPullParser> xpp;
    
    int       type;
    NSURL    *oldURL = [self URLForBoardName:boardName];
    NSString *origDir = [[oldURL path] lastPathComponent];
    NSURL    *newURL = nil;

    UTIL_DEBUG_WRITE2(@"Name:%@ Old:%@", boardName, [oldURL stringValue]);
    UTIL_DEBUG_WRITE1(@"HTML response was:¥n"
    @"----------------------------------------¥n"
    @"%@", htmlContents);
    if (!oldURL || !origDir) {
        return NO;
    }

    xpp = [[[SGXmlPullParser alloc] initHTMLParser] autorelease];
    [xpp setInputSource:htmlContents];

    // Setting up features
    [xpp setFeature:NO forKey:SGXmlPullParserDisableEntityResolving];
    
    type = [xpp nextName:@"html" type:XMLPULL_START_TAG options:NSCaseInsensitiveSearch];
    while ((type = [xpp next]) != XMLPULL_END_DOCUMENT) {
        if (XMLPULL_START_TAG == [xpp eventType] && NSOrderedSame == [[xpp name] caseInsensitiveCompare:@"a"]) {
            NSString *dir;
            NSString *href = [xpp attributeForName:@"href"];

            dir = [href lastPathComponent];
            UTIL_DEBUG_WRITE2(@"  href=%@ dir=%@", href, dir);
            if (![dir isEqualToString:origDir]) {
                continue;
            }
            href = [[href copy] autorelease];
            newURL = [NSURL URLWithString:href];
        }
    }
    
    if (newURL) {
    	NSString *newHost = [newURL host];
    	if ([newHost isEqualToString:[oldURL host]] || [newHost hasSuffix:@"u.la"]) {
//        if ([[newURL host] isEqualToString : [oldURL host]]) {
            return NO;
        }
        return [self movedBoardWasFound:boardName newLocation:newURL oldLocation:oldURL];
    }
    return NO;
}

- (BOOL)tryToDetectMovedBoard:(NSString *)boardName
{
    NSURL  *URL = [self URLForBoardName:boardName];
	NSURLRequest	*req_;
	BOOL	canHandle_;
    NSURLResponse	*response;
	NSError	*error;
    NSData *data;
    NSString *contents;

    // We can do nothing.
    if (!URL) return NO;
	
    NSLog(@"BathyScaphe try to detect moved BBS:%@ URL:%@", boardName, [URL absoluteString]);
    
	req_ = [NSURLRequest requestWithURL:URL];
	canHandle_ = [NSURLConnection canHandleRequest:req_];
	if (!canHandle_) return NO;

	data = [NSURLConnection sendSynchronousRequest:req_ returningResponse:&response error:&error];

    if (!data) {
		NSLog(@"Error: %@", [error localizedDescription]);
		return NO;
	}

    if (NULL == nsr_strncasestr((const char*)([data bytes]), "<html", [data length])) {
		return NO;
	}
    
    contents = [NSString stringWithData:data encoding:NSShiftJISStringEncoding];
	    
    return [self detectMovedBoardWithResponseHTML:contents boardName:boardName];
}
@end


@implementation BoardManager(Notification)
- (void)boardListDidChange:(NSNotification *)notification
{
	UTILAssertNotificationName(notification, CMRBBSListDidChangeNotification);
	UTILAssertKindOfClass([notification object], SmartBoardList);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:([notification object] == [self defaultList])
			 			? CMRBBSManagerDefaultListDidChangeNotification
						: CMRBBSManagerUserListDidChangeNotification
														object:self];
    
    [self saveListsIfNeeded];
}

- (BOOL)saveNoNameDict
{
	NSString *errorStr = [NSString string];
	NSMutableDictionary	*noNameDict_ = [self noNameDict];
	NSData *binaryData_ = [NSPropertyListSerialization dataFromPropertyList:noNameDict_
																	 format:NSPropertyListBinaryFormat_v1_0
														   errorDescription:&errorStr];

	if (!binaryData_) {
		NSLog(@"BoardManager failed to serialize noNameDict using NSPropertyListSerialization.");
		return [noNameDict_ writeToFile:[[self class] NNDFilepath] atomically:YES];
	}

	return [binaryData_ writeToFile:[[self class] NNDFilepath] atomically:YES];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	UTILAssertNotificationName(notification, NSApplicationWillTerminateNotification);
	UTILAssertNotificationObject(notification, NSApp);
	
	[self saveListsIfNeeded];
	[self saveNoNameDict];
}

- (BOOL)saveListsIfNeeded
{	
	if ([[self userList] isEdited]) {
		[[self userList] writeToFile:[self userBoardListPath] atomically:YES];
		[[self userList] setIsEdited:NO];
	}
	if ([[self defaultListWithoutNeedingInitialize] isEdited]) {
		[[self defaultList] writeToFile:[self defaultBoardListPath] atomically:YES];
		[[self defaultList] setIsEdited:NO];
	}
	return YES;
}
@end
