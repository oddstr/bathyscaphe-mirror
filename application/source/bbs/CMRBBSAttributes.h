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
 * @abstract    掲示板
 * @discussion  

掲示板の各情報。掲示板名、およびURL。

ただし、現在の情報のみでサーバ移転などの情報は保持しない。
処理を単純化するため、それらは特殊な処理として扱う。

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
