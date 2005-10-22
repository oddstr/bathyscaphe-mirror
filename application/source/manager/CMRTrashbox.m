//:CMRTrashbox.m
#import "CMRTrashbox.h"
#import "CocoMonar_Prefix.h"
#import <SGAppKit/SGAppKit.h>

// Constants
NSString *const CMRTrashboxWillPerformNotification	= @"CMRTrashboxWillPerformNotification";
NSString *const CMRTrashboxDidPerformNotification	= @"CMRTrashboxDidPerformNotification";

NSString *const kAppTrashUserInfoFilesKey		= @"Files";
NSString *const kAppTrashUserInfoStatusKey		= @"Status";

@implementation CMRTrashbox
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(trash);
@end


@implementation CMRTrashbox(FileOperation)
- (BOOL) performWithFiles : (NSArray *) filenames
{
	BOOL				isSucceeded_;
	NSMutableDictionary	*info_;
	OSErr				error_;
	
	if(nil == filenames || 0 == [filenames count]) return NO;
	
	info_ = [NSMutableDictionary dictionaryWithObject : filenames 
											   forKey : kAppTrashUserInfoFilesKey];
	UTILNotifyInfo(
		CMRTrashboxWillPerformNotification,
		info_);
	
	isSucceeded_ = [[NSWorkspace sharedWorkspace] moveFilesToTrash : filenames];
	error_ = isSucceeded_ ? noErr : -1;

	[info_ setObject : [NSNumber numberWithInt : error_]
			  forKey : kAppTrashUserInfoStatusKey];

	UTILNotifyInfo(
		CMRTrashboxDidPerformNotification,
		info_);
	
	return isSucceeded_;
}
@end
