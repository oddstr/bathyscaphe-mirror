//: CMRFileManager.m
/**
  * $Id: CMRFileManager.m,v 1.6 2007/08/07 14:07:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRFileManager.h"

#import <SGFoundation/SGFoundation.h>
#import <AppKit/NSApplication.h>
#import <CocoMonar/CMRSingletonObject.h>
#import <CocoMonar/CMRFiles.h>
//#import <CocoMonar/NSBundle+CMRExtensions.h>
#import "UTILKit.h"



// ----------------------------------------
// N o t i f i c a t i o n s
// ----------------------------------------
NSString *const CMRFileManagerDidUpdateFileNotification = @"CMRFileManagerDidUpdateFileNotification";


@interface CMRFileManagerWatchFile : NSObject
{
    @private
    SGFileLocation *location;
    NSDate         *lastDate;
}
- (id) initWithFileRef : (SGFileRef *) aFileRef;
- (id) initWithFileLocation : (SGFileLocation *) aFile;
- (SGFileRef *) fileRef;
- (NSDate *) lastDate;
- (void) setLastDate : (NSDate *) aLastDate;

@end

@implementation CMRFileManagerWatchFile
//
// P R I V A T E 
// 
- (void) setFileRef : (SGFileRef *) aFileRef
{
    [location autorelease];
    location = [[aFileRef fileLocation] retain];
}
- (void) setFileLocation : (SGFileLocation *) aFile
{
    NSDate *last;
    
    [location autorelease];
    location = [aFile retain];
    
    last = [location exists]
            ? [[location fileRef] modifiedDate]
            : [NSDate date];
    [self setLastDate : last];
}

//
// P U B L I C
//
- (id) initWithFileRef : (SGFileRef *) aFileRef
{
    return [self initWithFileLocation : [aFileRef fileLocation]];
}
- (id) initWithFileLocation : (SGFileLocation *) aFile
{
    if (self = [super init]) {
        [self setFileLocation : aFile];
        
        UTILDebugWrite2(@"  Watch file at %@ (date:%@)",
            aFile, [self lastDate]);
    }
    return self;
}
- (void) dealloc
{
    [location release];
    [lastDate release];
    
    [super dealloc];
}

- (SGFileRef *) fileRef
{
    return [location fileRef];
}
- (NSDate *) lastDate
{
	return lastDate;
}
- (void) setLastDate : (NSDate *) aLastDate
{
    id tmp;
    
    tmp = lastDate;
    lastDate = [aLastDate retain];
    [tmp release];
}
@end


@implementation CMRFileManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

- (id) init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter]
			addObserver : self
			selector : @selector(applicationDidBecomeActive:)
			name : NSApplicationDidBecomeActiveNotification
			object : NSApp];
        [self watchFileSet];  // allocate
	}
	return self;
}
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	
	[m_dataRootDirectory release];
	[m_dataRootDirectoryPath release];
	[m_watchFiles release];
	
	[super dealloc];
}

- (void) addFileChangedObserver : (id              ) anObserver 
                       selector : (SEL             ) aSelector 
                       location : (SGFileLocation *) aFile
{

    CMRFileManagerWatchFile *watchFile;
    
    if (nil == anObserver || NULL == aSelector || nil == aFile) {
        [NSException raise:NSInvalidArgumentException
            format:@"NULL arguments."];
    }
    
    watchFile = [[CMRFileManagerWatchFile alloc] initWithFileLocation : aFile];
    [[self watchFileSet] addObject : watchFile];
    
    [[NSNotificationCenter defaultCenter]
        addObserver:anObserver
        selector:aSelector 
        name:CMRFileManagerDidUpdateFileNotification
        object:self];
    
}
- (void) addFileChangedObserver : (id         ) anObserver 
                       selector : (SEL        ) aSelector 
                           file : (SGFileRef *) aFile
{
    [self addFileChangedObserver:anObserver selector:aSelector location:[aFile fileLocation]];
}


- (NSString *) dataRootDirectoryPath
{
	if (nil == m_dataRootDirectoryPath)
		[self updateDataRootDirectory];
	
	return m_dataRootDirectoryPath;
}
- (SGFileRef *) dataRootDirectory
{
	if (nil == m_dataRootDirectory)
		[self updateDataRootDirectory];
	
	return m_dataRootDirectory;
}
- (SGFileRef *) supportDirectory
{
	return [SGFileRef applicationSpecificFolderRef];
}
- (SGFileRef *) supportDirectoryWithName : (NSString *) dirName
{
	SGFileRef		*parent_;
	SGFileRef		*directory_;
	
	parent_ = [self supportDirectory];
	directory_ = [parent_ fileRefWithChildName : dirName
						 createDirectory : YES];
	directory_ = [directory_ fileRefResolvingLinkIfNeeded];
	
	if (nil == directory_ || NO == [directory_ isDirectory]) {
		NSLog(@"Can't create special folder at %@",
			[[parent_ filepath] stringByAppendingPathComponent : dirName]);
	}
	
	return directory_;
}
// ~/Library/Application Support/CocoMonar/<fileName>
- (NSString *) supportFilepathWithName : (NSString   *) aFileName
					  resolvingFileRef : (SGFileRef **) aFileRefPtr
{
	SGFileRef	*support_;
	SGFileRef	*fileRef_;
	
	if (0 == [aFileName length]) {
		[NSException raise:NSInvalidArgumentException
					format:@"Invalid (empty) File name was passed."];
	}
	
	support_ = [self supportDirectory];

NS_DURING
	//UTILAssertNotNil(support_);
	UTILAssertNotNilArgument(support_, aFileName);
	
NS_HANDLER
	if ([[localException name] isEqualToString : NSInvalidArgumentException]) {
		NSBeep();
		NSRunCriticalAlertPanel(NSLocalizedString(@"cannotRunTitle", "Alert Panel"), @"%@\n\n%@",
								NSLocalizedString(@"Terminate",@"Quit"), nil, nil, 
								NSLocalizedString(@"cannotRun",@"we can't resolve/create application support file/folder(s)."), localException);
		[NSApp terminate : self];

	} else {
		[localException raise];
	}
NS_ENDHANDLER

	fileRef_ = [support_ fileRefWithChildName : aFileName];
	fileRef_ = [fileRef_ fileRefResolvingLinkIfNeeded];
	
	if (aFileRefPtr != NULL) *aFileRefPtr = fileRef_;
	
	return fileRef_ 
			? [fileRef_ filepath]
			: [[support_ filepath] stringByAppendingPathComponent : aFileName];
}

- (NSString *)userDomainDesktopFolderPath
{
    CFURLRef        folderURL;
    FSRef           folderRef;
    CFStringRef     folderPath;
    OSErr           err;
	NSString		*returnPath = nil;

    err = FSFindFolder(kUserDomain, kDesktopFolderType, kDontCreateFolder, &folderRef);
    if (err == noErr) {
		folderURL = CFURLCreateFromFSRef(kCFAllocatorSystemDefault, &folderRef);
		if (folderURL) {
			folderPath = CFURLCopyFileSystemPath(folderURL, kCFURLPOSIXPathStyle);
			if (folderPath) {
				returnPath = [NSString stringWithString:(NSString *)folderPath];
				CFRelease(folderPath);
			}
			CFRelease(folderURL);
		}
	}
	return returnPath;
}
@end



@implementation CMRFileManager(Cache)
- (NSMutableSet *) watchFileSet
{
    if (nil == m_watchFiles) {
        m_watchFiles = [[NSMutableSet alloc] init];
    }
    return m_watchFiles;
}
- (void) updateWatchedFiles
{
    NSEnumerator            *iter;
    CMRFileManagerWatchFile *watchFile;
    

    iter = [[self watchFileSet] objectEnumerator];
    while (watchFile = [iter nextObject]) {
        SGFileRef   *f = [watchFile fileRef];
        NSDate      *lastDate = [watchFile lastDate];
        NSDate      *date = [f modifiedDate];
        
        UTILDebugWrite3(
            @"Compare watchFile(%@)\n"
            @" date:%@\n"
            @" last:%@", f, date, lastDate);
        
        if (NSOrderedDescending == [date compare:lastDate]) {
            NSDictionary *userInfo;
            
            UTILDebugWrite1(@"Update File %@", f);
            userInfo = [NSDictionary dictionaryWithObject : f
                            forKey : kCMRChangedFileRef];
            
            [[NSNotificationCenter defaultCenter]
                postNotificationName : CMRFileManagerDidUpdateFileNotification
                object : self
                userInfo: userInfo];
            // update last date. (file may be updated in delegate method)
            [watchFile setLastDate : [[watchFile fileRef] modifiedDate]];
        }
    }
}
- (void) updateDataRootDirectory
{
	[m_dataRootDirectory autorelease];
	[m_dataRootDirectoryPath autorelease];
	m_dataRootDirectory = nil;
	m_dataRootDirectoryPath = nil;
	
	m_dataRootDirectory = [self supportDirectoryWithName : CMRDocumentsDirectory];
	m_dataRootDirectoryPath = [m_dataRootDirectory filepath];
	[m_dataRootDirectory retain];
	[m_dataRootDirectoryPath retain];
	
}
- (void) applicationDidBecomeActive : (NSNotification *) theNotification
{
	UTILAssertNotificationName(
		theNotification,
		NSApplicationDidBecomeActiveNotification);
	UTILAssertNotificationObject(
		theNotification,
		NSApp);
	
	[self updateDataRootDirectory];
	[self updateWatchedFiles];
}
@end



void CMRDebugWriteObject(id obj, NSString *filename)
{
	SGFileRef	*folder_;
	NSString	*filepath_;
	
	folder_ = [[CMRFileManager defaultManager] supportDirectoryWithName : CMRLogsDirectory];
	filepath_ = [folder_ filepath];
	filepath_ = [filepath_ stringByAppendingPathComponent : filename]; 
	
	[obj writeToFile:filepath_ atomically:YES];
}
