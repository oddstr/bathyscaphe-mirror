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
	NSData			*ja_data_;
	
	boardName_ = [filepath stringByDeletingLastPathComponent];
	boardName_ = [boardName_ lastPathComponent];
	
	ja_data_ = [boardName_ dataUsingEncoding : NSShiftJISStringEncoding];
	
	boardName_ = [[NSString alloc] initWithData : ja_data_
							encoding : NSShiftJISStringEncoding];
	
	return [boardName_ autorelease];
	
}

- (NSString *) threadPathWithBoardName : (NSString *) boardName
                         datIdentifier : (NSString *) datIdentifier
{
	NSString		*filepath_;
	
	if(nil == boardName || nil == datIdentifier)
		return nil;

	//NSLog(@"Info - boardName is %@ (length: %i), and datIdentifier is %@", boardName, [boardName length], datIdentifier);
	filepath_ = [self directoryWithBoardName : boardName];
	//NSLog(@"dirWithBName result : %@", filepath_);
	filepath_ = [filepath_ stringByAppendingPathComponent : datIdentifier];
	//NSLog(@"strByApdPathCpt result : %@", filepath_);
	filepath_ = [filepath_ stringByDeletingPathExtension];
	//NSLog(@"strByDelPathExt result : %@", filepath_);
	
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
	NSString	*filepath_;
	
	filepath_ = [[CMRFileManager defaultManager] dataRootDirectoryPath];
	return [filepath_ stringByAppendingPathComponent : boardName];
}
@end
