//: NSString+Japanese.h
/**
  * $Id: NSString+Japanese.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#ifndef NSSTRING_JAPANESE_H_INCLUDED
#define NSSTRING_JAPANESE_H_INCLUDED

#import <Foundation/Foundation.h>
#import <SGFoundation/SGBase.h>


SG_DECL_BEGIN

/* �S�p�E���p�𖳎����Č��� */
SG_EXPORT
NSRange SGStringSearch_JP(NSString *src, NSString *subString, unsigned options, NSRange searchRange);


enum {
	SGZenkakuHankakuInsensitiveSearch = 128
};

@interface NSString(JapaneseStringExtensions)
/*
Additional Option
--------------------------------
SGZenkakuHankakuInsensitiveSearch
�S�p�E���p�𖳎����Č���
*/
- (NSRange) searchRangeOfString : (NSString *) subString
					    options : (unsigned  ) mask
					      range : (NSRange   ) aRange;
@end


SG_DECL_END

#endif /* NSSTRING_JAPANESE_H_INCLUDED */
