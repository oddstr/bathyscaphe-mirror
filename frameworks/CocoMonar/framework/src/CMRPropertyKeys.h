//: CMRPropertyKeys.h
/**
  * $Id: CMRPropertyKeys.h,v 1.1.1.1 2005/05/11 17:51:19 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


extern NSString *const ThreadPlistContentsKey;
extern NSString *const ThreadPlistLengthKey;
extern NSString *const ThreadPlistBoardNameKey;
extern NSString *const ThreadPlistIdentifierKey;
extern NSString *const CMRThreadWindowFrameKey;
extern NSString *const CMRThreadLastReadedIndexKey;
extern NSString *const CMRThreadVisibleRangeKey;
extern NSString *const CMRThreadUserStatusKey;


extern NSString *const ThreadPlistContentsIndexKey;
extern NSString *const ThreadPlistContentsNameKey;
extern NSString *const ThreadPlistContentsMailKey;
extern NSString *const ThreadPlistContentsDateKey;
extern NSString *const ThreadPlistContentsDatePrefixKey;	//Hummmmmm........
extern NSString *const ThreadPlistContentsIDKey;
extern NSString *const ThreadPlistContentsMessageKey;
extern NSString *const ThreadPlistContentsBeProfileKey;
extern NSString *const CMRThreadContentsStatusKey;		// NSNumber
extern NSString *const CMRThreadContentsHostKey;


extern NSString *const BoardPlistURLKey;
extern NSString *const BoardPlistContentsKey;
extern NSString *const BoardPlistNameKey;

extern NSString *const CMRThreadTitleKey;
extern NSString *const CMRThreadLastLoadedNumberKey;
extern NSString *const CMRThreadLogFilepathKey;
extern NSString *const CMRThreadNumberOfMessagesKey;
extern NSString *const CMRThreadNumberOfUpdatedKey;
extern NSString *const CMRThreadSubjectIndexKey;
extern NSString *const CMRThreadStatusKey;

extern NSString *const CMRThreadCreatedDateKey;
extern NSString *const CMRThreadModifiedDateKey;


extern NSString *const CMRBBSListItemsPboardType;
extern NSString *const CMRFavoritesItemsPboardType;
extern NSString *const CMRAttributeInnerLinkScheme;



extern NSString *const CMRBBSManagerUserListDidChangeNotification;
extern NSString *const CMRBBSManagerDefaultListDidChangeNotification;


extern NSString *const CMRBBSListDidChangeNotification;

extern NSString *const AppDefaultsLayoutSettingsUpdatedNotification;

extern NSString *const CMRApplicationWillResetNotification;
extern NSString *const CMRApplicationDidResetNotification;



#define APP_APPLICATION_NAME				@"CocoMonar"
