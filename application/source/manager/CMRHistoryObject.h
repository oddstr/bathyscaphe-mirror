/**
  * $Id: CMRHistoryObject.h,v 1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * CMRHistoryObject.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CocoMonar_Prefix.h"


@protocol CMRHistoryObject<CMRPropertyListCoding, NSObject>
// 履歴の重複チェック
- (BOOL) isHistoryEqual : (id) anObject;
@end

