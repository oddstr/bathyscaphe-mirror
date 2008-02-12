//: CMRDocumentTypes.m
/**
  * $Id: CMRDocumentTypes.m,v 1.4 2008/02/12 16:48:41 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRDocumentTypes.h"



// ���ރ^�C�v
NSString *const CMRBBSDocumentType		= @"2channel Board File Format"; // deprecated in RainbowJerk and later.
NSString *const CMRBrowserDocumentType	= @"CocoMonar 2ch Format"; // available in RainbowJerk and later.
NSString *const CMRThreadDocumentType	= @"CocoMonar Log Format";
NSString *const CMRReplyDocumentType	= @"CocoMonar Reply Format";

// �t�@�C����
NSString *const CMRAppSubjectTextFileName	= @"subject.txt";
NSString *const CMRThreadsListPlistFileName	= @"ThreadsList.plist";
NSString *const BSHeadTextFileName = @"head.txt"; // Available in SilverGull and later.
NSString *const BSLocalRulesRTFFileName = @"LocalRules.rtf"; // Available in SilverGull and later.

// �g���q
NSString *const CMRThreadDocumentPathExtension = @"thread";

NSString *const CMRApp2chDATPathExtension	= @"dat";
NSString *const CMRApp2chIdxPathExtension	= @"idx";
NSString *const CMRAppIdxFormatExtension	= @"fmt";


