//: SGFileRef.h
/**
  * $Id: SGFileRef.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>
#import <ApplicationServices/ApplicationServices.h>
#import <SGFoundation/SGFoundationBase.h>

@class SGFileLocation;

/*!
 * @class       SGFileRef
 * @abstract    File System Reference Wrapper class
 * @discussion  File System Reference Wrapper class
 */

@interface SGFileRef : SGBaseObject<NSCopying>
{
    @private
    FSRef m_fsRef;
}
+ (id) fileRefWithFileURL : (NSURL *) anURL;
- (id) initWithFileURL : (NSURL *) anURL;

+ (id) fileRefWithFSRef : (FSRef *) fsRef;
- (id) initWithFSRef : (FSRef *) fsRef;

+ (id) fileRefWithPath : (NSString *) filepath;
- (id) initWithPath : (NSString *) filepath;



- (FSRef *) getFSRef;
- (SGFileLocation *) fileLocation;
- (NSString *) filepath;
- (NSString *) filename;
- (NSString *) pathExtension;

- (NSURL *) fileURL;
- (NSDate *) modifiedDate;

- (BOOL) isDirectory;
- (BOOL) isPackage;

- (long) nodeID;
- (BOOL) nodeID : (long *) nodeID
    isDirectory : (BOOL *) flag;

- (BOOL) existsInFolder : (FolderType) folderType;
- (BOOL) existsInTrash;
@end



@interface SGFileRef(AllocateOtherRef)
// Find Folders
+ (id) searchDirectoryInDomain : (FSVolumeRefNum) vRefNum
					folderType : (OSType        ) folderType
					willCreate : (BOOL          ) willCreate;
+ (id) homeDirectory;

- (id) parentFileReference;
- (id) fileRefOfResolvedAliasFile;

- (id) fileRefCreateChildWithName : (NSString            *) aName
						whichInfo : (FSCatalogInfoBitmap  ) whichInfo
					  catalogInfo : (const FSCatalogInfo *) catalogInfo;
- (id) fileRefCreateChildWithName : (NSString *) aName
					     fileType : (OSType    ) fileHFSTypeCode
					  creatorType : (OSType    ) fileHFSCreatorCode;

- (id) fileRefWithChildName : (NSString *) aName;
- (id) fileRefWithChildName : (NSString *) aName 
            createDirectory : (BOOL      ) flag;
@end



@interface SGFileRef(AliasManagerSupport)
- (BOOL) isAliasFile;
- (BOOL) isSymbolicLink;
- (NSString *) pathContentOfResolvedAliasFile;
- (NSString *) pathContentResolvingLinkIfNeeded;
- (id) fileRefResolvingLinkIfNeeded;
@end



@interface SGFileRef(LaunchServicesSupport)
// Finder: Location link string
- (NSString *) displayPath;
- (NSString *) displayName;
- (NSString *) kindString;

- (OSStatus) copyItemInfo : (LSRequestedInfo   ) inWhichInfo
                 itemInfo : (LSItemInfoRecord *) outItemInfo;
- (LSItemInfoFlags) itemInfoFlags;
- (BOOL) fileHFSCreatorCode : (OSTypePtr) creator
                   fileType : (OSTypePtr) type;
- (OSType) fileHFSCreatorCode;
- (OSType) fileHFSTypeCode;
@end
