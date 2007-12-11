//
//  CMRThreadSignature.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/12/09.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//
  
#import <Foundation/Foundation.h>
#import "CMRHistoryObject.h"

@interface CMRThreadSignature : NSObject<NSCopying, CMRHistoryObject, CMRPropertyListCoding>
{
	NSString	*m_identifier;
	NSString	*m_boardName;
}

+ (id)threadSignatureFromFilepath:(NSString *)filepath;
- (id)initFromFilepath:(NSString *)filepath;

+ (id)threadSignatureWithIdentifier:(NSString *)identifier boardName:(NSString *)boardName;
- (id)initWithIdentifier:(NSString *)identifier boardName:(NSString *)boardName;

- (NSString *)identifier;
- (NSString *)boardName;

//- (NSString *)filepathExceptsExtention;
- (NSString *)datFilename;
- (NSString *)idxFileName;

//- (NSString *)localDATFilePath;
//- (NSString *)idxFilePath;
- (NSString *)threadDocumentPath;
@end
