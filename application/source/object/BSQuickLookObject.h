//
//  BSQuickLookObject.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/02.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>
@class CMRThreadSignature, CMRThreadMessage;

@interface BSQuickLookObject : NSObject {
	NSString	*m_threadTitle;
	CMRThreadSignature	*m_threadSignature;
	CMRThreadMessage	*m_threadMessage;

	NSURLConnection	*m_currentConnection;
	NSMutableData	*m_receivedData;
	BOOL	m_isLoading;
	NSError	*m_lastError;
}

- (id)initWithThreadTitle:(NSString *)title signature:(CMRThreadSignature *)signature;

- (void)cancelDownloading;

- (NSURL *)boardURL;

- (NSString *)threadTitle;
- (CMRThreadSignature *)threadSignature;
- (CMRThreadMessage *)threadMessage;

- (BOOL)isLoading;
- (NSError *)lastError;

#pragma mark For Subclass
+ (BOOL)canInitWithURL:(NSURL *)url;
- (NSURL *)resourceURL;
- (NSURLRequest *)requestForDownloadingQLContent;
- (CMRThreadMessage *)threadMessageFromString:(NSString *)source;
@end


extern NSString *const BSQuickLookErrorDomain;
