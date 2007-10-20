//: String+Utils.h
/**
  * $Id: String+Utils.h,v 1.2 2007/10/20 02:21:29 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>


@interface NSObject(SGStringUtils)
- (NSString *) stringValue;
@end



@interface NSString(SGStringUtils)
+ (NSString *) yenmark;
+ (NSString *) backslash;

- (BOOL) isEmpty;
- (NSRange) range;

- (BOOL) boolValue;
- (NSString *) stringValue;
- (unsigned) hexIntValue;
- (unsigned) unsignedIntValue;
@end



@interface NSAttributedString(SGStringUtils)
- (BOOL) isEmpty;
- (NSRange) range;
- (NSString *) stringValue;
@end



// Network Encoding
@interface NSData(SGNetEncoding)
// base64
//- (NSString *) stringByUsingBase64Encoding;
// URL Encoding
- (NSString *) stringByUsingURLEncoding;
@end



@interface NSString(SGNetEncoding)
// base64
//- (NSData *) dataUsingBase64Decoding;

//- (NSString *) stringByEncodingBase64UsingEncoding : (NSStringEncoding) encoding;
//- (NSString *) stringByDecodingBase64UsingEncoding : (NSStringEncoding) encoding;
// URL Encoding
//- (NSData *) dataUsingURLDecoding;

- (NSString *) stringByURLEncodingUsingEncoding : (NSStringEncoding) encoding;

// Deprecated in BathyScaphe 1.6 and later. Use -[NSString stringByReplacingPercentEscapesUsingEncoding:] instead.
//- (NSString *) stringByURLDecodingUsingEncoding : (NSStringEncoding) encoding;
@end



@interface NSDictionary(SGNetEncoding)
- (NSString *) queryUsingEncoding : (NSStringEncoding) encoding;

// NSURL
//- (NSDictionary *) queryDictionary;
@end
