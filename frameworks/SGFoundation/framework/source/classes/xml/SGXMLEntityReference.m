//: SGXMLEntityReference.m
/**
  * $Id: SGXMLEntityReference.m,v 1.2 2007/08/07 14:07:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "SGXMLEntityReference.h"
#import "PrivateDefines.h"
#import <Foundation/Foundation.h>
#import <SGFoundation/NSBundle-SGExtensions.h>
#import <SGFoundation/NSDictionary-SGExtensions.h>



#define kXHTMLEntityReferenceTableFile		@"xml_entities.plist"


static NSDictionary *SGXHTMLEntityReferenceTable(void)
{
	static NSDictionary *kEntityReferenceTable = nil;
	if(nil == kEntityReferenceTable){
		NSString	*filepath_;
		NSBundle	*bundle_;
		
		bundle_ = kSGFoundationBundle;
		UTILCAssertNotNil(bundle_);
		
		filepath_ = [bundle_ pathForResourceWithName : kXHTMLEntityReferenceTableFile];
		NSCAssert1(filepath_, @"Can't load file <%@>", kXHTMLEntityReferenceTableFile);
		
		kEntityReferenceTable = [[NSDictionary alloc] initWithContentsOfFile : filepath_];
		NSCAssert1(
			kEntityReferenceTable != nil, 
			@"Can't create dictionary from file <%@>", 
			filepath_);
	}
	return kEntityReferenceTable;
}

// "#123" or "#xAA"
static Boolean SGXMLConvertCharRefToUniChar(
				CFStringRef			theCharacterReference,
				UniChar				*theUniChar)
{
	NSScanner	*scanner_ = nil;
	int			code_;
	BOOL		scanResult_;
	
	UTILRequireCondition(
		theCharacterReference != NULL &&
		CFStringGetLength(theCharacterReference) > 2,
		ErrUnicodeCharacterWithEntity);
	UTILRequireCondition(
		'#' == CFStringGetCharacterAtIndex(theCharacterReference, 0),
		ErrUnicodeCharacterWithEntity);
	
	scanner_ = [NSScanner scannerWithString : 
				(NSString*)theCharacterReference];
	[scanner_ setScanLocation : 1];
	
	if('x' == CFStringGetCharacterAtIndex(theCharacterReference, 1)){
		[scanner_ setScanLocation : 2];
		scanResult_ = [scanner_ scanHexInt : (unsigned *)&code_];
	}else{
		[scanner_ setScanLocation : 1];
		scanResult_ = [scanner_ scanInt : &code_];
	}
	
	UTILRequireCondition(
		scanResult_ && code_ >= 0,
		ErrUnicodeCharacterWithEntity);
	
	if(theUniChar != NULL)
//		*theUniChar = CFSwapInt32BigToHost(code_);
		*theUniChar = code_;
	
	return true;

ErrUnicodeCharacterWithEntity:
	return false;
}

// 0xFFFFより大きいものはサロゲートペアに変換
static Boolean SGXMLConvertCharRefToBytes(
											CFStringRef			theCharacterReference,
											UInt8				*theByte)
{
	NSScanner	*scanner_ = nil;
	int			code_;
	BOOL		scanResult_;
	
	UTILRequireCondition(
						 theCharacterReference != NULL &&
						 CFStringGetLength(theCharacterReference) > 2,
						 ErrUnicodeCharacterWithEntity);
	UTILRequireCondition(
						 '#' == CFStringGetCharacterAtIndex(theCharacterReference, 0),
						 ErrUnicodeCharacterWithEntity);
	
	scanner_ = [NSScanner scannerWithString : 
		(NSString*)theCharacterReference];
	[scanner_ setScanLocation : 1];
	
	if('x' == CFStringGetCharacterAtIndex(theCharacterReference, 1)){
		[scanner_ setScanLocation : 2];
		scanResult_ = [scanner_ scanHexInt : (unsigned *)&code_];
	}else{
		[scanner_ setScanLocation : 1];
		scanResult_ = [scanner_ scanInt : &code_];
	}
	
	UTILRequireCondition(
						 scanResult_ && code_ >= 0,
						 ErrUnicodeCharacterWithEntity);
	
	if(theByte != NULL)
		if ( code_ > 0xFFFF ) {
			// 数値文字参照はビッグエンディアンなので、バイト列をそのまま処理
			UInt32 tmpcode;
			UInt16 upper, lower;
			UInt16 *sp;
			code_ -= 0x010000;
			tmpcode = (UInt32)code_;
			tmpcode >>= 10;
			upper = 0xD800 + tmpcode;
			tmpcode = (UInt32)code_;
			tmpcode <<= 22;
			tmpcode >>= 22;
			lower = 0xDC00 + tmpcode;
			// 戻す時にエンディアンを合わせる
			sp = (UInt16 *)theByte;
			*sp = CFSwapInt16BigToHost(upper);
			*sp++;
			*sp = CFSwapInt16BigToHost(lower);
		} else {
			UInt32 *ucp = (UInt32 *)theByte;
			*ucp = CFSwapInt32BigToHost((UInt32)code_);
		}
	
	return true;
	
ErrUnicodeCharacterWithEntity:
		return false;
}

Boolean SGXMLCharacterForEntityReference(
				CFStringRef			theEntityReference,
				UniChar				*theUniChar)
{
	CFStringRef		entityValue_ = NULL;
	
	entityValue_ = 	(CFStringRef)[SGXHTMLEntityReferenceTable()
				stringForKey : (NSString*)theEntityReference];
	NSCAssert1(
		NULL == entityValue_ || 1 == CFStringGetLength(entityValue_),
		@"Entity Value must be 1 Character. but was (%u)",
		CFStringGetLength(entityValue_));
	if(NULL == entityValue_){
		return SGXMLConvertCharRefToUniChar(theEntityReference, theUniChar);
	}
	
	if(theUniChar != NULL)
		*theUniChar = CFStringGetCharacterAtIndex(entityValue_, 0);
	
	return true;
}

CFStringRef SGXMLStringForEntityReference(
				CFStringRef			theEntityReference)
{
	CFStringRef		entityValue_ = NULL;
	
	entityValue_ = 	(CFStringRef)[SGXHTMLEntityReferenceTable()
				stringForKey : (NSString*)theEntityReference];
	NSCAssert1(
		NULL == entityValue_ || 1 == CFStringGetLength(entityValue_),
		@"Entity Value must be 1 Character. but was (%u)",
		CFStringGetLength(entityValue_));
	if(NULL == entityValue_){
		UInt8		code_[4];
		if(SGXMLConvertCharRefToBytes(theEntityReference, (UInt8 *)&code_)){
			entityValue_ = CFStringCreateWithBytes(
											   kCFAllocatorDefault,
											   code_,
											   4,
											   kCFStringEncodingUnicode,
											   true);
		}
	}
	
	return entityValue_;
}