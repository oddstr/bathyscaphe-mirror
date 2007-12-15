/**
 * $Id: CMRFileManager.h,v 1.6 2007/12/15 16:20:53 tsawada2 Exp $
 * 
 * CMRFileManager.h
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#import <Foundation/Foundation.h>



@class SGFileRef;
@class SGFileLocation;

@interface CMRFileManager : NSObject
{
	@private
	SGFileRef      *m_dataRootDirectory;
	NSString       *m_dataRootDirectoryPath;
//    NSMutableSet   *m_watchFiles;
}

+ (id) defaultManager;

/*!
 * @method        addFileChangedObserver:selector:file:
 * @abstract      Registers anObserver to receive notifications with
 *                the CMRFileManagerDidUpdateFileNotification for aFile
 * @discussion    
 *   Registers anObserver to receive notifications with
 *   the CMRFileManagerDidUpdateFileNotification for aFile.
 *   When aFile has been changed by filesystem, or other 
 *   application, CMRFileManager posts CMRFileManagerDidUpdateFileNotification 
 *   containing the object CMRFileManager. 
 *
 * @param  anObserver an Observer will recieve notification.
 * @param  aSelector selector
 * @param  aFile File as SGFileRef
 *
 * @see CMRFileManagerDidUpdateFileNotification
 */
/*- (void) addFileChangedObserver : (id         ) anObserver 
                       selector : (SEL        ) aSelector 
                           file : (SGFileRef *) aFile;
- (void) addFileChangedObserver : (id              ) anObserver 
                       selector : (SEL             ) aSelector 
                       location : (SGFileLocation *) aFile;*/

// CMRDocumentsDirectory
- (NSString *) dataRootDirectoryPath;
- (SGFileRef *) dataRootDirectory;

//
// ~/Library/Application Support/CocoMonar
// 
- (SGFileRef *) supportDirectory;
- (SGFileRef *) supportDirectoryWithName : (NSString *) dirName;

// ~/Library/Application Support/CocoMonar/<fileName>
- (NSString *) supportFilepathWithName : (NSString   *) aFileName
					  resolvingFileRef : (SGFileRef **) aFileRefPtr;

//
// ~/Desktop
// Available in CocoMonar Framework 1.5.1 and later.
//
- (NSString *)userDomainDesktopFolderPath;

//
// ~/Downloads (on Mac OS X 10.5 and later), or ~/Desktop
// Available in CocoMonar Framework 1.6 and later.
- (NSString *)userDomainDownloadsFolderPath;

//
// ~/Library/Logs
// Available in CocoMonar Framework 1.6v2 and later.
- (NSString *)userDomainLogsFolderPath;
@end


@interface CMRFileManager(Cache)
//- (NSMutableSet *) watchFileSet;
//- (void) updateWatchedFiles;
- (void) updateDataRootDirectory;
@end

// ----------------------------------------
// N o t i f i c a t i o n s
// ----------------------------------------
/*!
 * @const       CMRFileManagerDidUpdateFileNotification
 * @abstract    Posted when a registered file has been changed.
 * @discussion  
 *   Posted when a registered file has been changed.
 *   You can register file by using addFileChangedObserver:file: method.
 *
 *   The notification object is the shared CMRFileManager instance.
 *   The userInfo dictionary contains the following information:
 *
 *   Key                   Value
 *   ------------------------------------------
 *   kCMRChangedFileRef    a SGFileRef instance
 */
//#define kCMRChangedFileRef @"CMRChangedFileRef"
//extern NSString *const CMRFileManagerDidUpdateFileNotification;



// ----------------------------------------
// M i s c e l l a n e o u s
// ----------------------------------------
/*! 
 * @function        CMRDebugWriteObject
 * @abstract        Writes out file for debug
 * @discussion      Writes out object as file for debug in 
 * ~/Library/Application Support/CocoMonar/Logs directory
 * 
 * @param obj      An object will be written
 * @param filename Filename
 */
extern void CMRDebugWriteObject(id obj, NSString *filename);
