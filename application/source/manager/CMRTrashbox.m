//:CMRTrashbox.m
#import "CMRTrashbox_p.h"
#import "CMRFavoritesManager.h"



//////////////////////////////////////////////////////////////////////
////////////////////// [ íËêîÇ‚É}ÉNÉçíuä∑ ] //////////////////////////
//////////////////////////////////////////////////////////////////////
NSString *const CMRTrashboxWillPerformNotification	= @"CMRTrashboxWillPerformNotification";
NSString *const CMRTrashboxDidPerformNotification	= @"CMRTrashboxDidPerformNotification";



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
	
	isSucceeded_ = [[NSWorkspace sharedWorkspace]
						moveFilesToTrash : filenames];
	error_ = isSucceeded_ ? noErr : -1;
	[info_ setObject : [NSNumber numberWithInt : error_]
			  forKey : kAppTrashUserInfoStatusKey];
			  
	if (isSucceeded_)
		[[CMRFavoritesManager defaultManager] removeFromFavoritesWithPathArray : filenames];


	UTILNotifyInfo(
		CMRTrashboxDidPerformNotification,
		info_);
	
	return isSucceeded_;
}
// not available
- (BOOL) deleteFiles
{
	return NO;
}
@end
