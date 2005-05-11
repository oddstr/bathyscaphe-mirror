//: CMXFileManager.h
/**
  * $Id: CMXFileManager.h,v 1.1.1.1 2005/05/11 17:51:07 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>

@class SGFileRef;



@interface CMXFileManager : NSObject
+ (SGFileRef *) dataRootDirectory;
// dataRootPath直下のファイル
+ (SGFileRef *) dataFileWithChildName : (NSString *) childName
					  createDirectory : (BOOL      ) create;

+ (SGFileRef *) boardDirectoryWithName : (NSString *) aName;
+ (SGFileRef *) boardDirectoryWithName : (NSString *) aName
								create : (BOOL      ) willCreate;
+ (SGFileRef *) threadFileWithBoardName : (NSString *) boardName
                          datIdentifier : (NSString *) datIdentifier;
@end



// ファイルの保存
@interface CMXFileManager(SaveDocument)
+ (BOOL) writeData : (NSData    *) aData
			  into : (SGFileRef *) containerRef
			  name : (NSString  *) filename
	      fileType : (OSType     ) fileHFSTypeCode
	   creatorType : (OSType     ) fileHFSCreatorCode;
+ (BOOL) writeTextData : (NSData    *) aData
			      into : (SGFileRef *) containerRef
			      name : (NSString  *) filename;
@end




// - supportDirectoryWithName:
#define CMXLogsDirectory			@"Logs"
#define CMXDocumentsDirectory		@"Documents"
#define CMXResourcesDirectory		@"Resources"
#define CMXBBSMenuDirectory			@"Bookmarks"

@interface CMXFileManager(ApplicationSupport)
//
// ~/Library/Application Support/CocoMonar
// 
+ (SGFileRef *) supportDirectory;
+ (SGFileRef *) supportDirectoryWithName : (NSString *) dirName;
@end
