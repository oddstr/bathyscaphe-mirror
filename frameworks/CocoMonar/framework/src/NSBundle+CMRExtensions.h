/**
  * $Id: NSBundle+CMRExtensions.h,v 1.1.1.1 2005/05/11 17:51:19 tsawada2 Exp $
  * 
  * NSBundle+CMRExtensions.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import <SGFoundation/SGFoundation.h>


@interface NSImage(CMRExtensions)
/*!
 * @method      imageAppNamed:preferUserDirectory:
 * @abstract    ���[�U�̃T�|�[�g�f�B���N�g����D��I�ɒT��
 * @discussion  
 * @param name  �摜��
 * @result      �摜
 */
+ (id) imageAppNamed : (NSString *) aName;
@end



@interface NSBundle(CMRExtensions)
/*!
 * @method      mergedDictionaryWithName
 * @discussion
	Contents/Resources/
	~/Library/Application Support/CocoMonar/Resources
	�ɂ��鎫���t�@�C�����}�[�W
 * @result      �}�[�W��������
 */
+ (NSDictionary *) mergedDictionaryWithName : (NSString *) filename;
@end
