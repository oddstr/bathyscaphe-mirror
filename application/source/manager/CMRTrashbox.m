//
//  CMRTrashbox.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/21.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRTrashbox.h"
#import "CocoMonar_Prefix.h"
#import <SGAppKit/SGAppKit.h>
#import "DatabaseManager.h"

NSString *const CMRTrashboxDidPerformNotification	= @"CMRTrashboxDidPerformNotification";

NSString *const kAppTrashUserInfoFilesKey		= @"Files";
NSString *const kAppTrashUserInfoStatusKey		= @"Status";
NSString *const kAppTrashUserInfoAfterFetchKey  = @"Fetch";

@implementation CMRTrashbox
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(trash);

- (BOOL)performWithFiles:(NSArray *)filenames fetchAfterDeletion:(BOOL)shouldFetch
{
	BOOL				isSucceeded;
	NSMutableDictionary	*info;
	OSErr				err;
	
	if (!filenames || [filenames count] == 0) return NO;
	
	isSucceeded = [[NSWorkspace sharedWorkspace] moveFilesToTrash:filenames];
	err = isSucceeded ? noErr : -1;

	info = [NSDictionary dictionaryWithObjectsAndKeys:filenames, kAppTrashUserInfoFilesKey,
		[NSNumber numberWithBool:shouldFetch], kAppTrashUserInfoAfterFetchKey, 
		[NSNumber numberWithInt:err], kAppTrashUserInfoStatusKey, NULL];

	if (isSucceeded) [[DatabaseManager defaultManager] cleanUpItemsWhichHasBeenRemoved:filenames];

	UTILNotifyInfo(
		CMRTrashboxDidPerformNotification,
		info);
	
	return isSucceeded;
}
@end
