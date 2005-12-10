/**
  * $Id: CMRThreadSignature.h,v 1.2 2005/12/10 12:39:44 tsawada2 Exp $
  * 
  * CMRThreadSignature.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>
#import "CMRHistoryObject.h"

// CMRBBSSignature îÒàÀë∂Ç…èëÇ´ä∑Ç¶
//@class CMRBBSSignature;
@class SGFileRef;


@interface CMRThreadSignature : SGBaseObject<NSCopying, CMRHistoryObject, CMRPropertyListCoding>
{
	NSString			*m_identifier;
	//CMRBBSSignature		*m_BBSSignature; // îpé~
	NSString			*m_BBSName; // íuÇ´ä∑Ç¶
}
+ (id) threadSignatureFromFilepath : (NSString *) filepath;
- (id) initFromFilepath : (NSString *) filepath;

//+ (id) threadSignatureWithIdentifier : (NSString        *) anIdentifier
//						BBSSignature : (CMRBBSSignature *) bbsSignature;
+ (id) threadSignatureWithIdentifier : (NSString *) anIdentifier BBSName : (NSString *) bbsName;

//- (id) initWithIdentifier : (NSString        *) anIdentifier
//			 BBSSignature : (CMRBBSSignature *) bbsSignature;
- (id) initWithIdentifier : (NSString *) anIdentifier
				  BBSName : (NSString *) bbsName;

- (NSString *) identifier;
//- (CMRBBSSignature *) BBSSignature;
- (NSString *) BBSName;

- (NSString *) filepathExceptsExtention;
- (NSString *) datFilename;
- (NSString *) idxFileName;

- (NSString *) localDATFilePath;
- (NSString *) idxFilePath;
- (NSString *) threadDocumentPath;
@end
