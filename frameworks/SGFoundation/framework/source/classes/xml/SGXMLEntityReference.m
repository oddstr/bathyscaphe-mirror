//: SGXMLEntityReference.m
/**
  * $Id: SGXMLEntityReference.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
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
		scanResult_ = [scanner_ scanHexInt : &code_];
	}else{
		[scanner_ setScanLocation : 1];
		scanResult_ = [scanner_ scanInt : &code_];
	}
	
	UTILRequireCondition(
		scanResult_ && code_ >= 0,
		ErrUnicodeCharacterWithEntity);
	
	if(theUniChar != NULL)
		*theUniChar = code_;
	
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
		UniChar		code_;
		if(SGXMLConvertCharRefToUniChar(theEntityReference, &code_)){
			entityValue_ = 
				CFStringCreateWithCharacters(
					kCFAllocatorDefault,
					&code_,
					1);
		}
	}
	
	return entityValue_;
}