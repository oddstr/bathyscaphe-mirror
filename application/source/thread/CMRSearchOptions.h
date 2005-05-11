/**
  * $Id: CMRSearchOptions.h,v 1.1.1.1 2005/05/11 17:51:07 tsawada2 Exp $
  * 
  * CMRSearchOptions.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>
#import "CMRHistoryObject.h"


//
// ツールバーに使用するためにNSCodingが必要
//
@interface CMRSearchOptions : SGBaseObject<NSCopying, CMRHistoryObject, CMRPropertyListCoding, NSCoding>
{
	@private
	id			_findObject;
	id			_replaceObject;
	id			_userInfo;
	
	unsigned	_findOption;
}
+ (id) operationWithFindObject : (id      ) fobj
                       replace : (id      ) replacement
                      userInfo : (id      ) info
					    option : (unsigned) opt;
- (id) initWithFindObject : (id      ) fobj
                  replace : (id      ) replacement
                 userInfo : (id      ) info
			       option : (unsigned) opt;

- (id) findObject;
- (id) replaceObject;
- (id) userInfo;
- (unsigned int) findOption;

- (void) setOptionState : (BOOL        ) flag
                 option : (unsigned int) opt;
@end
