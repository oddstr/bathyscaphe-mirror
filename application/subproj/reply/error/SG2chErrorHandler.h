//
//  SG2chErrorHandler.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/15.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <SGFoundation/SGFoundation.h>
#import "w2chConnect.h"


@interface SG2chErrorHandler : NSObject<w2chErrorHandling>
{
	NSURL			*m_requestURL;
	NSError			*m_recentError;
	NSDictionary	*m_additionalFormsData;
}

+ (id)handlerWithURL:(NSURL *)anURL;
- (id)initWithURL:(NSURL *)anURL;

+ (BOOL)canInitWithURL:(NSURL *)anURL;


- (void)setRequestURL:(NSURL *)aRequestURL;
- (void)setRecentError:(NSError *)error;

- (BOOL)parseHTMLContents:(NSString *)htmlContents intoTitle:(NSString **)ptitle intoMessage:(NSString **)pbody;

- (NSDictionary *)scanAdditionalFormsWithHTML:(NSString *)htmlContents;
@end
