//
//  CMRDocumentController.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/19.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRDocumentController.h"
#import "Browser.h"

@implementation CMRDocumentController
// Will be removed after saying good-bye to Panther.
- (void)noteNewRecentDocumentURL:(NSURL *)aURL
{

}
/*
// For future use... after saying good-bye to Panther.
- (unsigned int)maximumRecentDocumentCount
{
	return 0;
}
*/

- (NSDocument *)documentAlreadyOpenForURL:(NSURL *)absoluteDocumentURL
{
	// 将来は NSURL-base に書き換えるべき
	NSArray			*documents;
	NSEnumerator	*iter;
	NSDocument		*document;
	NSString		*fileName;
	NSString		*documentPath;

	if (![absoluteDocumentURL isFileURL]) return nil;
	documentPath = [absoluteDocumentURL path];

	documents = [self documents];
	iter = [documents objectEnumerator];

	while (document = [iter nextObject]) {
		fileName = [document fileName];
//		fileName = [[document fileURL] path];
		if (!fileName && [document isKindOfClass:[Browser class]]) {
			fileName = [[(Browser *)document threadAttributes] path];
		}
		if (fileName && [fileName isEqualToString:documentPath]) {
			return document;
		}
	}
	return nil;
}
@end
