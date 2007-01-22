/**
  * $Id: CMRSearchOptions.h,v 1.2 2007/01/22 02:23:29 tsawada2 Exp $
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
// �c�[���o�[�Ɏg�p���邽�߂�NSCoding���K�v
//
@interface CMRSearchOptions : NSObject<NSCopying, CMRHistoryObject, CMRPropertyListCoding, NSCoding>
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
