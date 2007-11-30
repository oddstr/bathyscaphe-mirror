//: NSBundle-SGExtensions.h
/**
  * $Id: NSBundle-SGExtensions.h,v 1.3 2007/11/30 01:01:17 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>



@interface NSBundle(SGExtentions)
+ (NSDictionary *) applicationInfoDictionary;
+ (NSDictionary *) localizedAppInfoDictionary; // added in BathyScaphe 1.1 and later.
+ (NSString *) applicationName;
+ (NSString *) applicationVersion;
+ (NSString *) applicationHelpBookName; // added in BathyScaphe 1.1 and later.

- (NSString *) pathForResourceWithName : (NSString *) filename;
- (NSString *) pathForResourceWithName : (NSString *) filename
                           inDirectory : (NSString *) dirName;
@end

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
