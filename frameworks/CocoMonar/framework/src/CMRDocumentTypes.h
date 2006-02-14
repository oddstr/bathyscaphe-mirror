//: CMRDocumentTypes.h
/**
  * $Id: CMRDocumentTypes.h,v 1.2 2006/02/14 15:09:41 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


// 書類タイプ
extern NSString *const CMRBBSDocumentType; // deprecated in RainbowJerk and later.
extern NSString *const CMRBrowserDocumentType; // available in RainbowJerk and later. 
extern NSString *const CMRThreadDocumentType;
extern NSString *const CMRReplyDocumentType;

// ファイル名
extern NSString *const CMRAppSubjectTextFileName;
extern NSString *const CMRThreadsListPlistFileName;

// 拡張子 
extern NSString *const CMRThreadDocumentPathExtension;

extern NSString *const CMRApp2chDATPathExtension;
extern NSString *const CMRApp2chIdxPathExtension;
extern NSString *const CMRAppIdxFormatExtension;
