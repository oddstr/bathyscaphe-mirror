//: CMRBBSAttributes.h
/**
  * $Id: CMRBBSAttributes.h,v 1.1.1.1 2005/05/11 17:51:03 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>

/*!
 * @class       CMRBBSAttributes
 * @abstract    �f����
 * @discussion  

�f���̊e���B�f�����A�����URL�B

�������A���݂̏��݂̂ŃT�[�o�ړ]�Ȃǂ̏��͕ێ����Ȃ��B
������P�������邽�߁A�����͓���ȏ����Ƃ��Ĉ����B

 */

@interface CMRBBSAttributes : SGBaseObject
{
	@private
	NSString	*_name;
	NSURL		*_location;
}
- (id) initWithURL : (NSURL    *) anURL
			  name : (NSString *) aName;
- (id) initWithPath : (NSString *) aPath
		  directory : (NSString *) aDirectory
			   name : (NSString *) aName;

- (NSString *) name;
- (id) identifier;
- (NSURL *) URL;

/*
  2channel.brd compatibility
--------------------------------
  http://jbbs.shitaraba.com/business/767/
    -->
  (host) jbbs.shitaraba.com
  (path) jbbs.shitaraba.com/business
  (directory) 767

  @see CocoMonar.framework/CMRHostTypes.h
    CMRGetHostStringFromBoardURL()
    CMRGetHostStringFromBoardURLNoCopy()
*/
- (NSString *) host;
- (NSString *) path;
- (NSString *) directory;
@end
