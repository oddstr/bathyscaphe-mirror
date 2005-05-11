//: CMRResourceFileReader.h
/**
  * $Id: CMRResourceFileReader.h,v 1.1 2005/05/11 17:51:19 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


@interface CMRResourceFileReader : NSObject
{
	@private
	
	id			_contents;
	NSString	*_filepath;
}
+ (id) readerWithContentsOfFile : (NSString *) filePath;
+ (id) readerWithContents : (id) fileContents;
- (id) initWithContentsOfFile : (NSString *) filePath;
- (id) initWithContents : (id) fileContents;

/*!
 * @method      resourceClass
 * @abstract    リソースのクラスを指定
 *
 * @discussion  サブクラス側でリソースのクラスを指定するのに使う
 * @result      リソースのクラス(initWithContentsOfFile:に応答できるクラス)
 */
+ (Class) resourceClass;
- (id) fileContents;
- (void) setFileContents : (id) aFileContents;

- (NSString *) filepath;
@end



/*!
 * @exception CMRReaderUnsupportedFormatException
 * @abstract  サポートしていないファイルフォーマットを読もうとした
 */
extern NSString *const CMRReaderUnsupportedFormatException;
