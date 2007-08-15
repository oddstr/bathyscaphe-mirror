//
//  BSNGExpression.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/08/09.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>

@class OGRegularExpression;
@protocol CMRPropertyListCoding;

enum {
	BSNGExpressionAtName = 1 << 0,
	BSNGExpressionAtMail = 1 << 1,
	BSNGExpressionAtMessage = 1 << 2,
};

#define BSNGExpressionAtAll	(BSNGExpressionAtName|BSNGExpressionAtMail|BSNGExpressionAtMessage)

@interface BSNGExpression : NSObject<CMRPropertyListCoding> {
	NSString *m_NGExpression;
	unsigned int m_NGTargetMask;
	BOOL	m_isRegularExpression;

	OGRegularExpression	*m_OGRegExpInstance; // may be nil...
}

- (id)initWithExpression:(NSString *)string targetMask:(unsigned int)mask regularExpression:(BOOL)isRE;

- (NSString *)expression;
- (void)setExpression:(NSString *)string;

- (unsigned int)targetMask;
- (void)setTargetMask:(unsigned int)mask;

- (BOOL)checksName;
- (void)setChecksName:(BOOL)check;
- (BOOL)checksMail;
- (void)setChecksMail:(BOOL)check;
- (BOOL)checksMessage;
- (void)setChecksMessage:(BOOL)check;

- (BOOL)isRegularExpression;
- (void)setIsRegularExpression:(BOOL)isRE;

- (BOOL)validAsRegularExpression;

- (OGRegularExpression *)OGRegExpInstance;
- (void) setOGRegExpInstance:(OGRegularExpression *)instance;
@end

extern NSString *const BSNGExpressionErrorDomain;
