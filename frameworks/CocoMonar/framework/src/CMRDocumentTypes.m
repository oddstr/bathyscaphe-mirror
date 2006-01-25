//: CMRDocumentTypes.m
/**
  * $Id: CMRDocumentTypes.m,v 1.2 2006/01/25 11:22:03 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRDocumentTypes.h"
//#import <SGFoundation/SGFoundation.h>



// 書類タイプ
NSString *const CMRBBSDocumentType		= @"2channel Board File Format";
NSString *const CMRThreadDocumentType	= @"CocoMonar Log Format";
NSString *const CMRReplyDocumentType	= @"CocoMonar Reply Format";

// ファイル名
NSString *const CMRAppSubjectTextFileName	= @"subject.txt";
NSString *const CMRThreadsListPlistFileName	= @"ThreadsList.plist";

// 拡張子
NSString *const CMRThreadDocumentPathExtension = @"thread";

NSString *const CMRApp2chDATPathExtension	= @"dat";
NSString *const CMRApp2chIdxPathExtension	= @"idx";
NSString *const CMRAppIdxFormatExtension	= @"fmt";


