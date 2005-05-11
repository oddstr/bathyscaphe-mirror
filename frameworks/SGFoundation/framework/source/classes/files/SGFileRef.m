/**
 * $Id: SGFileRef.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
 * 
 * SGFileRef.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#import "SGFileRef.h"
#import "PrivateDefines.h"
#import "MoreFilesX.h"
#import <SGFoundation/SGFileLocation.h>
#import <SGFoundation/NSURL-SGExtensions.h>
#import <SGFoundation/NSDate-SGExtensions.h>



@implementation SGFileRef
- (BOOL) changeFileSystemReferenceWithFileURL : (NSURL *) anURL
{
	if(anURL != nil && [anURL isFileURL])
		return [anURL getFileSystemReference : [self getFSRef]];
	
	return NO;
}


+ (id) fileRefWithFileURL : (NSURL *) anURL
{
	return [[[self alloc] initWithFileURL : anURL] autorelease];
}
- (id) initWithFileURL : (NSURL *) anURL
{
	if(self = [self init]){
		if(NO == [self changeFileSystemReferenceWithFileURL : anURL]){
			[self release];
			return nil;
		}
	}
	return self;
}

+ (id) fileRefWithFSRef : (FSRef *) fsRef
{
	return [[[self alloc] initWithFSRef : fsRef] autorelease];
}
- (id) initWithFSRef : (FSRef *) fsRef
{
	if(NULL == fsRef){
		[self release];
		return nil;
	}
	
	if(self = [self init]){
		m_fsRef = *fsRef;
	}
	return self;
}

+ (id) fileRefWithPath : (NSString *) filepath
{
	return [[[self alloc] initWithPath : filepath] autorelease];
}
- (id) initWithPath : (NSString *) filepath
{
	NSURL		*fileURL_;
	
	if(nil == filepath || 0 == [filepath length]){
		[self release];
		return nil;
	}
	
	fileURL_ = [NSURL fileURLWithPath : filepath];
	return [self initWithFileURL : fileURL_];
}


//
// NSCopying
//
- (id) copyWithZone : (NSZone *) aZone
{
    return [self retain];
}

//
// NSObject
//
- (BOOL) isEqual : (id) other
{
	if(self == other) return YES;
	if(nil == other) return NO;
	
	if([other isKindOfClass : [self class]]){
		OSErr	result;
		
		result = FSCompareFSRefs([self getFSRef], [other getFSRef]);
		return (noErr == result);
	}
	
	return NO;
}
- (NSString *) description
{
    return [NSString stringWithFormat :
            @"<%@:%p> %@",
            [self className], self,
            [self filepath]];
}
- (unsigned) hash
{
    OSErr  err;
    SInt32 fileID;
    
    err = FSCreateFileIDRef(
            &m_fsRef,
            &fileID);
    if (noErr == err || fidExists == err || afpIDExists == err) {
        return (unsigned)fileID;
    }
    return 0;
}



- (FSRef *) getFSRef
{
	return &m_fsRef;
}
- (SGFileLocation *) fileLocation
{
    return [SGFileLocation fileLocationWithName:[self filename] directory:[self parentFileReference]];
}
- (NSString *) filepath
{
	OSErr		err;
	UInt8		path_[FRWK_SGFILEREF_PATHSIZE];
	
	if(NULL == [self getFSRef])
		return nil;
	
	err = FSRefMakePath(
				[self getFSRef],
				path_,
				FRWK_SGFILEREF_PATHSIZE);
	if(err != noErr)
		return nil;
	
	return [[NSFileManager defaultManager] 
				stringWithFileSystemRepresentation : path_
											length : strlen(path_)];
}
- (NSString *) filename
{
	HFSUniStr255	uniStr255_;
	OSErr			err;
	
	err = FSGetCatalogInfo(
				[self getFSRef],
				kFSCatInfoNone,
				NULL,
				&uniStr255_,
				NULL,
				NULL);
	if(err != noErr)
		return nil;
	
	return [NSString stringWithCharacters : uniStr255_.unicode
								   length : uniStr255_.length];
}

- (NSString *) pathExtension
{
	return [[self filename] pathExtension];
}
- (NSDate *) modifiedDate
{
    NSDate        *date = nil;
    OSStatus      ret;
    FSCatalogInfo catalogInfo;
    
    ret = FSGetCatalogInfo(
            &m_fsRef,
            kFSCatInfoNodeFlags + kFSCatInfoContentMod,
            &catalogInfo,
            NULL, NULL, NULL);
    UTILRequireCondition(noErr == ret, ErrModifiedDate);
    
    date = [NSDate dateWithUTCDateTime : &catalogInfo.contentModDate];
    
ErrModifiedDate:
    return date;
}

- (NSURL *) fileURL
{
	CFURLRef	URLRef_;
	
	if(NULL == [self getFSRef])
		return nil;
	
	URLRef_ = CFURLCreateFromFSRef(
				CFAllocatorGetDefault(),
				[self getFSRef]);
	return [(NSURL*)URLRef_ autorelease];
}

- (BOOL) isDirectory
{
	BOOL		isDir_;
	
	if([self nodeID:NULL isDirectory:&isDir_])
		return isDir_;
	
	return NO;
}
- (BOOL) isPackage
{
	return ((kLSItemInfoIsPackage & [self itemInfoFlags]) != 0);
}

- (long) nodeID
{
	long		nodeID_;
	
	if([self nodeID:&nodeID_ isDirectory:NULL])
		return nodeID_;
	
	return -1;
}

- (BOOL) nodeID : (long *) nodeID
    isDirectory : (BOOL *) flag
{
	OSErr	err;
	
	err = FSGetNodeID(
				[self getFSRef],
				nodeID,
				flag);
	if(noErr == err)
		return YES;
	
	return NO;
}

- (BOOL) existsInFolder : (FolderType) folderType
{
	SGFileRef		*parent_;
	long				spFolderID_;
	OSErr				error_;
	
	{
		FSRef			spFolder_;
		FSVolumeRefNum	vRefNum_;
		
		error_ = FSGetVRefNum([self getFSRef], &vRefNum_);
		require_noerr(error_, ErrFSGetVRefNum);
		error_ = FSFindFolder(
				vRefNum_, 
				folderType,
				false,
				&spFolder_);
		require_noerr(error_, ErrFSFindFolder);
		error_ = FSGetNodeID(&spFolder_, &spFolderID_, NULL);
		require_noerr(error_, ErrFSGetNodeID);
	}
	parent_ = self;
	
	while(parent_ != nil){
		long		nodeID_;
		
		if(NO == [parent_ nodeID:&nodeID_ isDirectory:NULL])
			goto Errparent_nodeID;
		
		if(spFolderID_ == nodeID_) return YES;
		
		parent_ = [parent_ parentFileReference];
	}
	
	return NO;
	
ErrFSFindFolder:
ErrFSGetNodeID:
ErrFSGetVRefNum:
Errparent_nodeID:

	return NO;

}

- (BOOL) existsInTrash
{
	return [self existsInFolder : kTrashFolderType];
}
@end



@implementation SGFileRef(AllocateOtherRef)
+ (id) searchDirectoryInDomain : (FSVolumeRefNum) vRefNum
					folderType : (OSType        ) folderType
					willCreate : (BOOL          ) willCreate
{
	OSErr				error_;
	FSRef				spFolder_;
	
	error_ = FSFindFolder(
					vRefNum, 
					folderType,
					willCreate,
					&spFolder_);
	if(error_ != noErr) return nil;
	
	return [self fileRefWithFSRef:&spFolder_];
}
+ (id) homeDirectory
{
	return [self searchDirectoryInDomain:kUserDomain folderType:kDomainTopLevelFolderType willCreate:YES];
}



- (id) parentFileReference
{
	FSRef		parent_;
	OSErr		error_;
	
	error_ = FSGetParentRef(
				[self getFSRef],
				&parent_);
	require_noerr(error_, ErrFSGetParentRef);
	// maybe root.
	if(NO == FSRefValid(&parent_)) return nil;
	
	return [[self class] fileRefWithFSRef : &parent_];
	
ErrFSGetParentRef:

	return nil;

}

- (id) fileRefOfResolvedAliasFile
{
	FSRef			fileSystemRef_;
	Boolean			isTargetFolder_;
	Boolean			wasAliased_;
	OSErr			error_;
	
	if(NO == [self isAliasFile]) return nil;
	
	fileSystemRef_ = *[self getFSRef];
	
	error_ = FSResolveAliasFile(
				&fileSystemRef_,
				YES,
				&isTargetFolder_,
				&wasAliased_);
	if(noErr == error_)
		return [[self class] fileRefWithFSRef : &fileSystemRef_];
	
	return nil;
}


- (id) fileRefCreateChildWithName : (NSString            *) aName
						whichInfo : (FSCatalogInfoBitmap  ) whichInfo
					  catalogInfo : (const FSCatalogInfo *) catalogInfo
{
	OSErr			err = noErr;
	
	UniCharCount	length_      = [aName length];
	const UniChar	*name_;
	UniChar			*nameBuffer_ = NULL;
	
	FSRef			childRef_;
	id				child_ = nil;
	
	if(nil == aName || 0 == length_ || kHFSPlusMaxFileNameChars < length_)
		return nil;
	
	name_ = CFStringGetCharactersPtr((CFStringRef)aName);
	if(NULL == name_){
		nameBuffer_ = malloc(sizeof(UniChar) * length_);
		if(NULL == nameBuffer_){
			UTILDebugWrite1(
				@"***ERROR*** %@ fail malloc()",
				UTIL_HANDLE_FAILURE_IN_METHOD);
			
			return nil;
		}
		
		[aName getCharacters : nameBuffer_];
		name_ = nameBuffer_;
	}
	
	err = FSCreateFileUnicode(
			[self getFSRef],
			length_,
			name_,
			whichInfo,
			catalogInfo,
			&childRef_,
			NULL);
	
	if(noErr == err)
		child_ = [[self class] fileRefWithFSRef : &childRef_];
	
	
	free(nameBuffer_);
	return child_;
}
- (id) fileRefCreateChildWithName : (NSString *) aName
					     fileType : (OSType    ) fileHFSTypeCode
					  creatorType : (OSType    ) fileHFSCreatorCode
{
	FileInfo		*fileInfo_;
	FSCatalogInfo	catalogInfo_;
	
	fileInfo_ = (FileInfo*)&catalogInfo_.finderInfo[0];
	BlockZero(fileInfo_, sizeof(FileInfo));
	
	fileInfo_->fileType = fileHFSTypeCode;
	fileInfo_->fileCreator = fileHFSCreatorCode;
	
	return [self fileRefCreateChildWithName:aName whichInfo:kFSCatInfoFinderInfo catalogInfo:&catalogInfo_];
}

- (id) fileRefWithChildName : (NSString *) aName 
			createDirectory : (BOOL      ) willCreateDir
{
	OSErr			error_;
	const UniChar	*name_;
	
	UniCharCount	length_      = [aName length];
	UniChar			*unicBuffer_ = NULL;
	id				instance_    = nil;
	FSRef			childRef_;
	
	if(nil == aName || kHFSPlusMaxFileNameChars < length_)
		return nil;
	
	name_ = CFStringGetCharactersPtr((CFStringRef)aName);
	if(NULL == name_){
		unicBuffer_ = malloc(sizeof(UniChar) * length_);
		if(NULL == unicBuffer_){
			UTILDebugWrite1(
				@"***ERROR*** %@ fail malloc()",
				UTIL_HANDLE_FAILURE_IN_METHOD);
			
			return nil;
		}
		
		[aName getCharacters : unicBuffer_];
		name_ = unicBuffer_;
	}
	
	
	error_ = FSMakeFSRefUnicode(
				[self getFSRef],
				length_,
				name_,
				kTextEncodingUnknown,
				&childRef_);
	
	// create Directory
	if((fnfErr == error_) && willCreateDir){
		error_ = FSCreateDirectoryUnicode(
					[self getFSRef], 
					[aName length], 
					name_, 
					kFSCatInfoNone,
					NULL, 
					&childRef_, 
					NULL, 
					NULL);
	}
	
	if(noErr == error_){
		instance_ = [[self class] fileRefWithFSRef : &childRef_];
	}
	
	free(unicBuffer_);
	return instance_;
}
- (id) fileRefWithChildName : (NSString *) aName
{
	return [self fileRefWithChildName : aName
					  createDirectory : NO];
}
@end



@implementation SGFileRef(AliasManagerSupport)
- (BOOL) isAliasFile : (BOOL *) isDirectoryFlag
{
	Boolean		aliasFileFlag_;
	OSErr		error_;
	
	error_ = FSIsAliasFile(
				[self getFSRef],
				&aliasFileFlag_,
				isDirectoryFlag);
	if(error_ != noErr){
		return NO;
	}
	
	return aliasFileFlag_;
}
- (BOOL) isAliasFile
{
	Boolean		isDirectoryFlag;
	return [self isAliasFile : &isDirectoryFlag];
}
- (BOOL) isSymbolicLink
{
	NSDictionary	*fileAttributes_;
	
	fileAttributes_ = [[NSFileManager defaultManager] 
							fileAttributesAtPath : [self filepath]
									traverseLink : NO];
	
	return [NSFileTypeSymbolicLink isEqualToString : [fileAttributes_ fileType]];
}
- (NSString *) pathContentOfResolvedAliasFile
{
	SGFileRef		*resolved_;
	
	if(NO == [self isAliasFile]) return nil;
	
	resolved_ = [self fileRefOfResolvedAliasFile];
	return [resolved_ filepath];
}
- (NSString *) pathContentResolvingLinkIfNeeded
{
	return [[self fileRefResolvingLinkIfNeeded] filepath];
}
- (id) fileRefResolvingLinkIfNeeded
{
	if([self isSymbolicLink]){
		NSString		*actualPath_;
		
		actualPath_ = [[NSFileManager defaultManager] 
							pathContentOfSymbolicLinkAtPath : [self filepath]];
		if(nil == actualPath_) return self;
		
		return [[self class] fileRefWithPath : actualPath_];
	}
	if([self isAliasFile])
		return [self fileRefOfResolvedAliasFile];
	
	return self;
}
@end



@implementation SGFileRef(LaunchServicesSupport)
- (NSString *) displayPath
{
	NSMutableString	*mpath_;
	SGFileRef		*fileRef_ = self;
	
	mpath_ = [NSMutableString string];
	while(1){
		NSString	*name_;
		
		name_ = [fileRef_ displayName];
		if(nil == name_)
			break;
		
		if([mpath_ length] != 0)
			[mpath_ insertString:@":" atIndex:0];
		
		[mpath_ insertString:name_ atIndex:0];
		
		fileRef_ = [fileRef_ parentFileReference];
		if(nil == fileRef_)
			break;
	}
	return mpath_;
}
- (NSString *) displayName
{
	NSString	*displayName_;
	OSStatus	error_;
	
	error_ = LSCopyDisplayNameForRef(
				[self getFSRef],
				(CFStringRef*)(&displayName_));
	require_noerr(error_, ErrLSCopyDisplayNameForRef);
	
	return [displayName_ autorelease];
	
ErrLSCopyDisplayNameForRef:
	return [[self filepath] lastPathComponent];
}

- (NSString *) kindString
{
	NSString	*kindString_;
	OSStatus	error_;
	
	error_ = LSCopyKindStringForRef(
				[self getFSRef],
				(CFStringRef*)(&kindString_));
	require_noerr(error_, err_LSCopyKindStringForRef);
	
	return [kindString_ autorelease];
	
	err_LSCopyKindStringForRef:
	return nil;
}


- (OSStatus) copyItemInfo : (LSRequestedInfo   ) inWhichInfo
                 itemInfo : (LSItemInfoRecord *) outItemInfo
{
	return LSCopyItemInfoForRef(
				[self getFSRef],
				inWhichInfo,
				outItemInfo);
}

- (BOOL) fileHFSCreatorCode : (OSTypePtr) creator
                   fileType : (OSTypePtr) type
{
	LSItemInfoRecord	record_;
	OSStatus			error_;
	
	error_ = [self copyItemInfo : kLSRequestTypeCreator
					   itemInfo : &record_];
	require_noerr(error_, err_copyItemInfo);
	
	if(creator != NULL) *creator = record_.creator;
	if(type != NULL) *type = record_.filetype;
	return YES;
	
	err_copyItemInfo:
	{
		return NO;
	}
}

- (OSType) fileHFSCreatorCode
{
	OSType		creator_;
	
	if(NO == [self fileHFSCreatorCode:&creator_ fileType:NULL])
		return 0;
	return creator_;
}
- (OSType) fileHFSTypeCode
{
	OSType		filetype_;
	
	if(NO == [self fileHFSCreatorCode:NULL fileType:&filetype_])
		return 0;
	return filetype_;
}

- (LSItemInfoFlags) itemInfoFlags
{
	LSItemInfoRecord	record_;
	OSStatus			error_;
	
	error_ = [self copyItemInfo : kLSRequestBasicFlagsOnly
					   itemInfo : &record_];
	if(noErr == error_)
		return record_.flags;
	
	return kLSItemInfoIsPlainFile;
}
@end
