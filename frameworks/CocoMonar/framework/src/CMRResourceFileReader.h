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
 * @abstract    ���\�[�X�̃N���X���w��
 *
 * @discussion  �T�u�N���X���Ń��\�[�X�̃N���X���w�肷��̂Ɏg��
 * @result      ���\�[�X�̃N���X(initWithContentsOfFile:�ɉ����ł���N���X)
 */
+ (Class) resourceClass;
- (id) fileContents;
- (void) setFileContents : (id) aFileContents;

- (NSString *) filepath;
@end



/*!
 * @exception CMRReaderUnsupportedFormatException
 * @abstract  �T�|�[�g���Ă��Ȃ��t�@�C���t�H�[�}�b�g��ǂ����Ƃ���
 */
extern NSString *const CMRReaderUnsupportedFormatException;
