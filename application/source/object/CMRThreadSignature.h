/**
  * $Id: CMRThreadSignature.h,v 1.1.1.1.4.1 2005/12/14 16:05:06 masakih Exp $
  * 
  * CMRThreadSignature.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <SGFoundation/SGFoundation.h>
#import <CocoMonar/CocoMonar.h>
#import "CMRHistoryObject.h"

// CMRBBSSignature ��ˑ��ɏ�������
//@class CMRBBSSignature;
@class SGFileRef;


@interface CMRThreadSignature : SGBaseObject<NSCopying, CMRHistoryObject, CMRPropertyListCoding>
{
	NSString			*m_identifier;
	//CMRBBSSignature		*m_BBSSignature; // �p�~
	NSString			*m_BBSName; // �u������
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
