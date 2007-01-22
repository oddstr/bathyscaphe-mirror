/**
  * $Id: CMRThreadSignature.h,v 1.4 2007/01/22 02:23:29 tsawada2 Exp $
  * 
  * CMRThreadSignature.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>
#import "CMRHistoryObject.h"

@class SGFileRef;


@interface CMRThreadSignature : NSObject<NSCopying, CMRHistoryObject, CMRPropertyListCoding>
{
	NSString			*m_identifier;
	NSString			*m_BBSName; // ’u‚«Š·‚¦
}
+ (id) threadSignatureFromFilepath : (NSString *) filepath;
- (id) initFromFilepath : (NSString *) filepath;

+ (id) threadSignatureWithIdentifier : (NSString *) anIdentifier BBSName : (NSString *) bbsName;

- (id) initWithIdentifier : (NSString *) anIdentifier
				  BBSName : (NSString *) bbsName;

- (NSString *) identifier;
- (NSString *) BBSName;

- (NSString *) filepathExceptsExtention;
- (NSString *) datFilename;
- (NSString *) idxFileName;

- (NSString *) localDATFilePath;
- (NSString *) idxFilePath;
- (NSString *) threadDocumentPath;
@end
