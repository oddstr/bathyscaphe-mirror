//
//  CMRDocumentFileManager.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/17.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRDocumentFileManager.h"
#import "CocoMonar_Prefix.h"

@implementation CMRDocumentFileManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

- (NSString *)threadDocumentFileExtention
{
	return @"thread";
//	return [[NSDocumentController sharedDocumentController] firstFileExtensionFromType:CMRThreadDocumentType];
}

- (NSString *)datIdentifierWithLogPath:(NSString *)filepath
{
	return [[filepath lastPathComponent] stringByDeletingPathExtension];
}

- (NSString *)boardNameWithLogPath:(NSString *)filepath
{
	NSString		*boardName_;
	CFMutableStringRef			normalized;
	
	if (!filepath) return nil;
	
	boardName_ = [filepath stringByDeletingLastPathComponent];
	boardName_ = [boardName_ lastPathComponent];
	
	normalized = (CFMutableStringRef)[[boardName_ mutableCopy] autorelease];
	CFStringNormalize(normalized, kCFStringNormalizationFormC);
	
	return (NSString *)normalized;
}

- (NSString *)threadPathWithBoardName:(NSString *)boardName datIdentifier:(NSString *)datIdentifier
{
	NSString		*filepath_;
	
	if (!boardName || !datIdentifier) return nil;

	filepath_ = [self directoryWithBoardName:boardName];
	filepath_ = [filepath_ stringByAppendingPathComponent:datIdentifier];
	filepath_ = [filepath_ stringByDeletingPathExtension];

	return [filepath_ stringByAppendingPathExtension:[self threadDocumentFileExtention]];
}

- (BOOL)isInLogFolder:(NSURL *)absoluteURL
{
	SGFileRef *logFileLoc = [SGFileRef fileRefWithFileURL:absoluteURL];
	SGFileRef *parentParentLoc = [[logFileLoc parentFileReference] parentFileReference];
	if (!parentParentLoc) return NO;

	SGFileRef *logFolderLoc = [[CMRFileManager defaultManager] dataRootDirectory];

	return ([parentParentLoc isEqual:logFolderLoc]);
}

- (BOOL)forceCopyLogFile:(NSURL *)absoluteURL boardName:(NSString *)boardName datIdentifier:(NSString *)datIdentifier destination:(NSURL **)outURL
{
	char	*target;
	OSStatus err;

	err = FSPathCopyObjectSync(
			[[absoluteURL path] fileSystemRepresentation],
			[[self directoryWithBoardName:boardName] fileSystemRepresentation],
			(CFStringRef)[datIdentifier stringByAppendingPathExtension:[self threadDocumentFileExtention]],
			&target,
			(kFSFileOperationDefaultOptions|kFSFileOperationOverwrite)
		  );

	if (err != noErr) return NO;

	if (outURL != NULL) {
		*outURL = [NSURL fileURLWithPath:[[NSFileManager defaultManager] stringWithFileSystemRepresentation:target length:strlen(target)]];
	}
	return YES;
}

- (SGFileRef *)ensureDirectoryExistsWithBoardName:(NSString *)boardName
{
	SGFileRef	*f;
	
	if (!boardName || [boardName isEmpty]) return nil;
	
	f = [[CMRFileManager defaultManager] dataRootDirectory];
	f = [f fileRefWithChildName:boardName createDirectory:YES];
	
	return f;
}

- (NSString *)directoryWithBoardName:(NSString *)boardName
{
	return [[self ensureDirectoryExistsWithBoardName:boardName] filepath];
}
@end
