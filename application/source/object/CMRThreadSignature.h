/**
  * $Id: CMRThreadSignature.h,v 1.1.1.1 2005/05/11 17:51:06 tsawada2 Exp $
  * 
  * CMRThreadSignature.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>
#import "CMRHistoryObject.h"


@class CMRBBSSignature;
@class SGFileRef;


@interface CMRThreadSignature : SGBaseObject<NSCopying, CMRHistoryObject, CMRPropertyListCoding>
{
	NSString			*m_identifier;
	CMRBBSSignature		*m_BBSSignature;
}
+ (id) threadSignatureFromFilepath : (NSString *) filepath;
- (id) initFromFilepath : (NSString *) filepath;

+ (id) threadSignatureWithIdentifier : (NSString        *) anIdentifier
						BBSSignature : (CMRBBSSignature *) bbsSignature;

- (id) initWithIdentifier : (NSString        *) anIdentifier
			 BBSSignature : (CMRBBSSignature *) bbsSignature;

- (NSString *) identifier;
- (CMRBBSSignature *) BBSSignature;
- (NSString *) BBSName;

- (NSString *) filepathExceptsExtention;
- (NSString *) datFilename;
- (NSString *) idxFileName;

- (NSString *) localDATFilePath;
- (NSString *) idxFilePath;
- (NSString *) threadDocumentPath;
@end
