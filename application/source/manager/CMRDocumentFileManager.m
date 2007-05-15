//:CMRDocumentFileManager.m
/**
  *
  * @see AppDefaults.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/15  9:47:47 PM)
  *
  */
#import "CMRDocumentFileManager.h"

#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"
//#import "CMRDocumentController.h"



@implementation CMRDocumentFileManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

- (NSString *) threadDocumentFileExtention
{
	// TestaRossa
	return @"thread";//[[NSDocumentController sharedDocumentController]
						//	firstFileExtensionFromType : CMRThreadDocumentType];
}

- (NSString *) datIdentifierWithLogPath : (NSString *) filepath
{
	return [[filepath lastPathComponent] stringByDeletingPathExtension];
}
- (NSString *) boardNameWithLogPath : (NSString *) filepath
{
	NSString		*boardName_;
	CFMutableStringRef			normalized;
	
	boardName_ = [filepath stringByDeletingLastPathComponent];
	boardName_ = [boardName_ lastPathComponent];
	
	normalized = (CFMutableStringRef)[[boardName_ mutableCopy] autorelease];
	CFStringNormalize(normalized, kCFStringNormalizationFormC);
	
	return (NSString *)normalized;
}

- (NSString *) threadPathWithBoardName : (NSString *) boardName
                         datIdentifier : (NSString *) datIdentifier
{
	NSString		*filepath_;
	
	if(nil == boardName || nil == datIdentifier)
		return nil;

	filepath_ = [self directoryWithBoardName : boardName];
	filepath_ = [filepath_ stringByAppendingPathComponent : datIdentifier];
	filepath_ = [filepath_ stringByDeletingPathExtension];

	return [filepath_ stringByAppendingPathExtension : 
						[self threadDocumentFileExtention]];
}



- (NSString *) threadsListPathWithBoardName : (NSString *) boardName
{
	return [[self directoryWithBoardName : boardName] 
			   stringByAppendingPathComponent : CMRThreadsListPlistFileName];
}

- (SGFileRef *) ensureDirectoryExistsWithBoardName : (NSString *) boardName
{
	SGFileRef	*f;
	
	if(nil == boardName || [boardName isEmpty])
		return nil;
	
	f = [[CMRFileManager defaultManager] dataRootDirectory];
	f = [f fileRefWithChildName:boardName createDirectory:YES];
	
	return f;
}
- (NSString *) directoryWithBoardName : (NSString *) boardName
{
//	NSString	*filepath_;
//	
//	filepath_ = [[CMRFileManager defaultManager] dataRootDirectoryPath];
//	return [filepath_ stringByAppendingPathComponent : boardName];
	return [[self ensureDirectoryExistsWithBoardName:boardName] filepath];
}
@end
