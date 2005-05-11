//: CMXFileManager.m
/**
  * $Id: CMXFileManager.m,v 1.1 2005/05/11 17:51:07 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CocoMonar_Prefix.h"
#import "CMXFileManager.h"
#import "CMXPreferences_p.h"
#import "MoreUtilities.h"



@implementation CMXFileManager
+ (SGFileRef *) dataRootDirectory
{
	return [self supportDirectoryWithName : CMXDocumentsDirectory];
}


// dataRootPath直下のファイル
+ (SGFileRef *) dataFileWithChildName : (NSString *) childName
					  createDirectory : (BOOL) create
{
	SGFileRef		*fileRef_;
	
	fileRef_ = [self dataRootDirectory];
	fileRef_ = [fileRef_ fileRefWithChildName : childName
							  createDirectory : create];
	return [fileRef_ fileRefResolvingLinkIfNeeded];
}

+ (SGFileRef *) boardDirectoryWithName : (NSString *) aName
{
	return [self boardDirectoryWithName:aName create:YES];
}
+ (SGFileRef *) boardDirectoryWithName : (NSString *) aName
								create : (BOOL      ) willCreate;
{
	return [self dataFileWithChildName:aName createDirectory:willCreate];
}
+ (NSString *) threadFilepathWithBoardName : (NSString *) boardName
                             datIdentifier : (NSString *) datIdentifier
{
	SGFileRef		*fileRef_;
	NSString		*filename_;
	
	UTILAssertNotNilArgument(boardName, @"boardName");
	UTILAssertNotNilArgument(datIdentifier, @"datIdentifier");
	
	filename_ = [datIdentifier stringByDeletingPathExtension];
	filename_ = [filename_ stringByAppendingPathExtension : CMRThreadDocumentPathExtension];
	
	fileRef_ = [self boardDirectoryWithName : boardName];
	return [[fileRef_ filepath] stringByAppendingPathComponent : filename_];
}
+ (SGFileRef *) threadFileWithBoardName : (NSString *) boardName
                          datIdentifier : (NSString *) datIdentifier
{
	SGFileRef		*fileRef_;
	NSString		*filename_;
	
	UTILAssertNotNilArgument(boardName, @"boardName");
	UTILAssertNotNilArgument(datIdentifier, @"datIdentifier");
	
	filename_ = [datIdentifier stringByDeletingPathExtension];
	filename_ = [filename_ stringByAppendingPathExtension : CMRThreadDocumentPathExtension];
	
	fileRef_ = [self boardDirectoryWithName : boardName];
	return [fileRef_ fileRefWithChildName : filename_];
}
@end



// ファイルの保存
@implementation CMXFileManager(SaveDocument)
+ (BOOL) writeData : (NSData    *) aData
			  into : (SGFileRef *) containerRef
			  name : (NSString  *) filename
	      fileType : (OSType     ) fileHFSTypeCode
	   creatorType : (OSType     ) fileHFSCreatorCode
{
	SGFileRef		*fileRef_   = nil;
	SGFileRef		*container_ = containerRef;
	OSErr			err         = noErr;
	
	UTILAssertNotNilArgument(aData, @"data");
	UTILAssertNotNilArgument(containerRef, @"containerRef");
	UTILAssertNotNilArgument(filename, @"filename");
	
	fileRef_ = [containerRef fileRefWithChildName:filename];
	if(fileRef_ != nil){
		// NSLog(@"  File Exsits.");
		UTILRequireCondition(
			NO == [fileRef_ isDirectory],
			ErrDirectoryExists);
		
		if([fileRef_ isAliasFile] || [fileRef_ isSymbolicLink]){
			// NSLog(@"  File was Alias/Symbolic File.");
			fileRef_ = [fileRef_ fileRefResolvingLinkIfNeeded];
			container_ = [fileRef_ parentFileReference];
		}
		// NSLog(@"  Delete Old File.");
		err = FSDeleteObject([fileRef_ getFSRef]);
	}
	if(noErr == err){
		fileRef_ = [container_ fileRefCreateChildWithName : filename
								     fileType : fileHFSTypeCode
								  creatorType : fileHFSCreatorCode];
	}
	UTILRequireCondition(container_, ErrFailSGFileRef);
	UTILRequireCondition(fileRef_, ErrFailSGFileRef);
	
	// 書き込み
	HFSUniStr255		forkName_;
	SInt16				forkRefNum_;
	
	err = FSGetDataForkName(&forkName_);
	UTILRequireCondition(noErr == err, ErrFSGetDataForkName);
	
	err = FSOpenFork(
				[fileRef_ getFSRef],
				(UniCharCount)forkName_.length,
				forkName_.unicode,
				fsWrPerm,
				&forkRefNum_);
	UTILRequireCondition(noErr == err, ErrFSOpenFork);
	
	err = FSWriteFork(
			forkRefNum_,
			fsFromStart,
			0,
			[aData length],
			[aData bytes],
			NULL);
	
	err = FSCloseFork(forkRefNum_);
	
	return (noErr == err);
	
ErrDirectoryExists:
ErrFailSGFileRef:
ErrFSGetDataForkName:
ErrFSOpenFork:
	return NO;
}
+ (BOOL) writeTextData : (NSData    *) aData
			      into : (SGFileRef *) containerRef
			      name : (NSString  *) filename
{
	return [self writeData:aData into:containerRef name:filename fileType:'TEXT' creatorType:0];
}
@end



@implementation CMXFileManager(ApplicationSupport)
//
// ~/Library/Application Support/CocoMonar
// 
+ (SGFileRef *) supportDirectory
{
	return [NSBundle CMXSupportDirectory];
}
+ (SGFileRef *) supportDirectoryWithName : (NSString *) dirName
{
	SGFileRef		*parent_;
	SGFileRef		*directory_;
	
	parent_ = [self supportDirectory];
	directory_ = [parent_ fileRefWithChildName : dirName
						 createDirectory : YES];
	directory_ = [directory_ fileRefResolvingLinkIfNeeded];
	
	if(nil == directory_ || NO == [directory_ isDirectory]){
		[CMRLogger severe : 
			@"Can't create special folder at %@",
			[[parent_ filepath] stringByAppendingPathComponent : dirName]];
	}
	
	return directory_;
}
@end
