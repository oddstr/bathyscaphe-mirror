/**
  * $Id: NSBundle+AppSupport.h,v 1.2 2006/01/25 11:22:03 tsawada2 Exp $
  * 
  * NSBundle+AppSupport.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import "NSBundle-SGExtensions.h"


@interface NSBundle(SGApplicationSupport)
// ~/Library/Application Support/(ExecutableName)
+ (NSBundle *) applicationSpecificBundle;
/*!
 * @method      mergedDictionaryWithName
 * @discussion
	Contents/Resources/
	~/Library/Application Support/CocoMonar/Resources
	にある辞書ファイルをマージ
 * @result      マージした辞書
 */
+ (NSDictionary *) mergedDictionaryWithName : (NSString *) filename;
@end
