//: CMRDocumentTypes.h
/**
  * $Id: CMRDocumentTypes.h,v 1.2 2006/02/14 15:09:41 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


// ���ރ^�C�v
extern NSString *const CMRBBSDocumentType; // deprecated in RainbowJerk and later.
extern NSString *const CMRBrowserDocumentType; // available in RainbowJerk and later. 
extern NSString *const CMRThreadDocumentType;
extern NSString *const CMRReplyDocumentType;

// �t�@�C����
extern NSString *const CMRAppSubjectTextFileName;
extern NSString *const CMRThreadsListPlistFileName;

// �g���q 
extern NSString *const CMRThreadDocumentPathExtension;

extern NSString *const CMRApp2chDATPathExtension;
extern NSString *const CMRApp2chIdxPathExtension;
extern NSString *const CMRAppIdxFormatExtension;
