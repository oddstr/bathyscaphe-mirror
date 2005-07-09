#import "CMRThreadAttributes.h"
#import "CMRBBSSignature.h"
#import "CMRThreadVisibleRange.h"
#import "CMRThreadSignature.h"

#import "CMRDocumentFileManager.h"
#import "BoardManager.h"
#import "AppDefaults.h"
#import "CMRHostHandler.h"
#import "CMRThreadUserStatus.h"



static NSString *const kCMROldVersionThreadURLKey = @"ThreadURL";

@implementation CMRThreadAttributes(Converter)
+ (BOOL) isNewThreadFromDictionary : (NSDictionary *) dict
{
	NSNumber	*s;
	
	s = [dict objectForKey : CMRThreadStatusKey];
	return s ? ThreadNewCreatedStatus == [s unsignedIntValue] : NO;
}
+ (int) numberOfUpdatedFromDictionary : (NSDictionary *) dict
{
	NSNumber		*count_;
	int				diffrence_;
	
	count_ = [dict objectForKey : CMRThreadNumberOfMessagesKey];
	UTILRequireCondition(count_, no_cached);
	diffrence_ = [count_ unsignedIntValue];
	
	count_ = [dict objectForKey : CMRThreadLastLoadedNumberKey];
	UTILRequireCondition(count_, no_cached);
	diffrence_ = diffrence_ - [count_ unsignedIntValue];
	
	UTILRequireCondition(diffrence_ >= 0, no_cached);
	
	return diffrence_;
	
	
	no_cached:
		return -1;
}
+ (NSString *) pathFromDictionary : (NSDictionary *) dict
{
	NSString		*boardName_;
	NSString		*datIdentifier_;
	
	if (nil == dict) return nil;
	boardName_ = [dict objectForKey : ThreadPlistBoardNameKey];
	if (nil == boardName_) {
		NSString		*path_;
		
		path_ = [dict objectForKey : CMRThreadLogFilepathKey];
		UTILAssertNotNil(path_);
		boardName_ = 
			[[CMRDocumentFileManager defaultManager]
						boardNameWithLogPath : path_];
	}
	
	datIdentifier_ = [self identifierFromDictionary : dict];
	return [[CMRDocumentFileManager defaultManager]
						threadPathWithBoardName : boardName_
								  datIdentifier : datIdentifier_];
}

+ (NSString *) identifierFromDictionary : (NSDictionary *) dict
{
	NSString		*datIdentifier_;
	
	if (nil == dict)
		return nil;
	
	datIdentifier_ = [dict objectForKey : ThreadPlistIdentifierKey];
	if (nil == datIdentifier_) {
		NSString		*path_;
		
		path_ = [dict objectForKey : CMRThreadLogFilepathKey];
		UTILRequireCondition(path_ != nil, try_old_format);
		
		datIdentifier_ = 
			[[CMRDocumentFileManager defaultManager]
						datIdentifierWithLogPath : path_];
	}
	return datIdentifier_;
	
	try_old_format:{
		NSString	*threadURLString_;
		
		threadURLString_ = [dict objectForKey : kCMROldVersionThreadURLKey];
		if (nil == threadURLString_)
			return nil;
		
		return [threadURLString_ lastPathComponent];
	}
}
+ (NSString *) boardNameFromDictionary : (NSDictionary *) dict
{
	return [dict stringForKey : ThreadPlistBoardNameKey];
}
+ (NSString *) threadTitleFromDictionary : (NSDictionary *) dict
{
	return [dict stringForKey : CMRThreadTitleKey];
}
+ (NSDate *) createdDateFromDictionary : (NSDictionary *) dict
{
	return [dict objectForKey : CMRThreadCreatedDateKey];
}
+ (NSDate *) modifiedDateFromDictionary : (NSDictionary *) dict
{
	return [dict objectForKey : CMRThreadModifiedDateKey];
}

+ (NSURL *) boardURLFromDictionary : (NSDictionary *) dict
{
	return [[BoardManager defaultManager] 
				URLForBoardName : [self boardNameFromDictionary : dict]];
}
+ (NSURL *) threadURLFromDictionary : (NSDictionary *) dict
{
	NSURL			*boardURL_;
	NSString		*dat_;
	CMRHostHandler	*handler_;
	
	boardURL_ = [self boardURLFromDictionary : dict];
	dat_ = [self identifierFromDictionary : dict];
	
	handler_ = [CMRHostHandler hostHandlerForURL : boardURL_];
	
	return [handler_ readURLWithBoard:boardURL_ datName:dat_];
}
// added by tsawada2 2004-10-27
+ (NSURL *) threadURLFromDictionary : (NSDictionary *) dict
					   withParamStr : (NSString *) paramStr
{
	NSURL			*boardURL_;
	NSString		*dat_;
	CMRHostHandler	*handler_;
	
	boardURL_ = [self boardURLFromDictionary : dict];
	dat_ = [self identifierFromDictionary : dict];
	
	handler_ = [CMRHostHandler hostHandlerForURL : boardURL_];
	
	return [handler_ readURLWithBoard:boardURL_ datName:dat_ paramStr:paramStr];
}
@end
