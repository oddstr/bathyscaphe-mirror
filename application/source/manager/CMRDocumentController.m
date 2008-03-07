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
- (void)noteNewRecentDocumentURL:(NSURL *)aURL
{
	// ブロックして、アップルメニューの「最近使った項目」への追加を抑制する
}

- (unsigned int)maximumRecentDocumentCount
{
	// BathyScaphe の「ファイル」＞「最近使った書類」サブメニューの生成を抑制する
	return 0;
}

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
		fileName = [[document fileURL] path];
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
