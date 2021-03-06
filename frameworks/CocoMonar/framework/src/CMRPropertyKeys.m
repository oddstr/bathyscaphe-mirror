//: CMRPropertyKeys.m
/**
  * $Id: CMRPropertyKeys.m,v 1.4 2008/06/08 03:29:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  * encoding="UTF-8"
  */

#import "CMRPropertyKeys.h"
#import <SGFoundation/NSBundle-SGExtensions.h>

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
NSString *const ThreadPlistContentsMilliSecKey  = @"MilliSec";
NSString *const ThreadPlistContentsDateRepKey  = @"DateRepresentation";

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

NSString *const BSThreadEnergyKey = @"Ikioi";

//board.plist
NSString *const BoardPlistURLKey		= @"URL";
NSString *const BoardPlistContentsKey	= @"Contents";
NSString *const BoardPlistNameKey		= @"Name";



//PboardTypes
NSString *const CMRBBSListItemsPboardType = @"CMRBBSListItemsPboardType";
//NSString *const CMRFavoritesItemsPboardType = @"CMRFavoritesItemsPboardType";
NSString *const BSThreadItemsPboardType = @"BSThreadItemsPboardType";
NSString *const BSFavoritesIndexSetPboardType = @"BSFavoritesIndexSetPboardType";

NSString *const CMRBBSManagerUserListDidChangeNotification = @"CMRBBSManagerUserListDidChangeNotification";
NSString *const CMRBBSManagerDefaultListDidChangeNotification = @"CMRBBSManagerDefaultListDidChangeNotification";
NSString *const CMRBBSListDidChangeNotification = @"CMRBBSListDidChangeNotification";
NSString *const AppDefaultsLayoutSettingsUpdatedNotification = @"AppDefaultsLayoutSettingsUpdateNotification";

NSString *const CMRApplicationWillResetNotification = @"CMRApplicationWillResetNotification";
NSString *const CMRApplicationDidResetNotification = @"CMRApplicationDidResetNotification";

@implementation NSBundle(UserAgentString)
+ (NSString *)applicationUserAgent
{
	return [NSString stringWithFormat:@"%@/%@", [NSBundle applicationName], [NSBundle applicationVersion]];
}

+ (NSString *)monazillaUserAgent
{
	const long	dolibVersion_ = (1 << 16);
		
	return [NSString stringWithFormat:@"Monazilla/%d.%02d (%@)", dolibVersion_ >> 16, dolibVersion_ & 0xffff, [self applicationUserAgent]];
}
@end
