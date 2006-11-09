//: CMRPropertyKeys.m
/**
  * $Id: CMRPropertyKeys.m,v 1.2.4.1 2006/11/09 18:11:38 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRPropertyKeys.h"


NSString *const ThreadPlistContentsIndexKey		= @"Index";

NSString *const ThreadPlistContentsNameKey		= @"Name";
NSString *const ThreadPlistContentsMailKey		= @"Mail";
NSString *const ThreadPlistContentsDateKey		= @"Date";
NSString *const ThreadPlistContentsDatePrefixKey= @"DatePrefix";	//Hummmmmm........
NSString *const ThreadPlistContentsIDKey		= @"ID";
NSString *const ThreadPlistContentsBeProfileKey = @"BeProfileLink";
NSString *const ThreadPlistContentsMessageKey	= @"Message";
NSString *const CMRThreadContentsStatusKey		= @"Status";
NSString *const CMRThreadContentsHostKey		= @"Host";
NSString *const ThreadPlistContentsMilliSecKey  = @"MilliSec"; // available in BathyScaphe 1.1.3 and later.
NSString *const ThreadPlistContentsDateRepKey  = @"DateRepresentation"; // available in BathyScaphe 1.1.3 and later.


NSString *const ThreadPlistContentsKey			= @"Contents";
NSString *const ThreadPlistLengthKey			= @"Length";
NSString *const ThreadPlistBoardNameKey			= @"BoardName";
NSString *const ThreadPlistIdentifierKey		= @"dat";
NSString *const CMRThreadWindowFrameKey			= @"WindowFrame";
NSString *const CMRThreadLastReadedIndexKey		= @"Last Index";
NSString *const CMRThreadVisibleRangeKey		= @"Visible Range";
NSString *const CMRThreadUserStatusKey			= @"Status";
NSString *const CMRThreadTitleKey				= @"Title";
NSString *const CMRThreadLastLoadedNumberKey	= @"Count";
NSString *const CMRThreadLogFilepathKey			= @"Path";
NSString *const CMRThreadNumberOfMessagesKey	= @"NewCount";
NSString *const CMRThreadNumberOfUpdatedKey		= @"Updated Count";
NSString *const CMRThreadSubjectIndexKey		= @"Number";
NSString *const CMRThreadStatusKey				= @"Status";

NSString *const CMRThreadCreatedDateKey			= @"CreatedDate";
NSString *const CMRThreadModifiedDateKey		= @"ModifiedDate";



//board.plist
NSString *const BoardPlistURLKey		= @"URL";
NSString *const BoardPlistContentsKey	= @"Contents";
NSString *const BoardPlistNameKey		= @"Name";



//PboardTypes
NSString *const CMRBBSListItemsPboardType = @"CMRBBSListItemsPboardType";
NSString *const CMRFavoritesItemsPboardType = @"CMRFavoritesItemsPboardType";
NSString *const BSThreadItemsPboardType = @"BSThreadItemsPboardType";

NSString *const CMRBBSManagerUserListDidChangeNotification = @"CMRBBSManagerUserListDidChangeNotification";
NSString *const CMRBBSManagerDefaultListDidChangeNotification = @"CMRBBSManagerDefaultListDidChangeNotification";
NSString *const CMRBBSListDidChangeNotification = @"CMRBBSListDidChangeNotification";
NSString *const AppDefaultsLayoutSettingsUpdatedNotification = @"AppDefaultsLayoutSettingsUpdateNotification";

NSString *const CMRApplicationWillResetNotification = @"CMRApplicationWillResetNotification";
NSString *const CMRApplicationDidResetNotification = @"CMRApplicationDidResetNotification";
