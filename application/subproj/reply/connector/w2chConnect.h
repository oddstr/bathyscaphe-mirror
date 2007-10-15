//
//  w2chConnect.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/15.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>

// Error Handling
// 対応表はReplyErrorCode.plistを参照
enum {
	k2chNoneErrorType 				= 0,		// 正常
	k2chEmptyDataErrorType			= 1,		// データなし
	k2chAnyErrorType				= 2,		// ＥＲＲＯＲ！
	k2chContributionCheckErrorType	= 3,		// 投稿確認

	k2chRequireNameErrorType		= 4,		// 名前いれてちょ
	k2chRequireContentsErrorType	= 5,		// 本文がありません。
	k2chSPIDCookieErrorType			= 6,		// クッキー確認！
	k2chDoubleWritingErrorType		= 7,		// 二重書き込み
	k2chWarningType					= 8,		// 注意事項
	
	
	k2chUnknownErrorType
};

@protocol w2chConnect<NSObject>
- (NSURLConnection *)connector;

- (NSURLResponse *)response;
- (void)setResponse:(NSURLResponse *)response;

- (NSURL *)requestURL;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (NSMutableData *)availableResourceData;

- (void)loadInBackground;

- (BOOL)writeForm:(NSDictionary *)forms;
@end

//Error Handling
@protocol w2chErrorHandling<NSObject>
- (NSURL *)requestURL;
- (NSError *)recentError;

- (NSDictionary *)additionalFormsData;
- (void)setAdditionalFormsData:(NSDictionary *)anAdditionalFormsData;

- (NSError *)handleErrorWithContents:(NSString *)contents;
@end


//Delegate
@interface NSObject(w2chConnectDelegate)
- (void)connector:(id<w2chConnect>)sender didFailURLEncoding:(NSArray *)contextInfo;

- (void)connectorResourceDidCancelLoading:(id<w2chConnect>)sender;
- (void)connectorResourceDidFinishLoading:(id<w2chConnect>)sender;
  
- (void)connector:(id<w2chConnect>)sender resourceDidFailLoadingWithError:(NSError *)error;
- (void)connector:(id<w2chConnect>)sender resourceDidFailLoadingWithErrorHandler:(id<w2chErrorHandling>)handler;
@end

// NSError domain constant
#define SG2chErrorHandlerErrorDomain	@"SG2chErrorHandlerErrorDomain"

// NSError userInfo constants
#define SG2chErrorTitleErrorKey		@"SG2chErrorHandler_Title"
#define SG2chErrorMessageErrorKey	@"SG2chErrorHandler_Message"
