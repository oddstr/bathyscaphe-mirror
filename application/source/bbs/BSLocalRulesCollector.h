//
//  BSLocalRulesCollector.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/11.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>


@interface BSLocalRulesCollector : NSObject {
	NSString			*m_boardName;
	NSAttributedString	*m_localRulesAttrString;
	NSDate				*m_lastDate;

	NSURLConnection	*m_currentConnection;
	NSMutableData	*m_receivedData;
	BOOL	m_isLoading;
	NSError	*m_lastError;
}

- (id)initWithBoardName:(NSString *)boardName;

- (void)cancelDownloading;

- (NSURL *)boardURL;

- (NSString *)boardName;
- (NSAttributedString *)localRulesAttrString;
- (NSDate *)lastDate;

- (BOOL)isLoading;
- (NSError *)lastError;
@end


extern NSString *const BSLocalRulesCollectorErrorDomain;
