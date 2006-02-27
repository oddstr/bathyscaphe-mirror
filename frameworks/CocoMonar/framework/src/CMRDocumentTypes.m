//: CMRDocumentTypes.m
/**
  * $Id: CMRDocumentTypes.m,v 1.1.1.1.4.2 2006/02/27 17:31:50 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRDocumentTypes.h"



// 書類タイプ
NSString *const CMRBBSDocumentType		= @"2channel Board File Format"; // deprecated in RainbowJerk and later.
NSString *const CMRBrowserDocumentType	= @"CocoMonar 2ch Format"; // available in RainbowJerk and later.
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


