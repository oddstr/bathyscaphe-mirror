//
//  BSLocalRulesCollector.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/11.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

// Error Codes
// これ以外に、http ステータスコードをそのままエラーコードとして返すこともある。
enum {
	BSLocalRulesCollectorErrorCannotReadFile = -101, /* LocalRules.rtf の読み込み失敗（注：この場合、自動的に再ダウンロードを試みる） */
	BSLocalRulesCollectorErrorCannotCreateAttrString = -102, /* ダウンロードしたデータが無いか、データから NSAttributedString の生成に失敗 */
};

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
- (void)reload;

- (NSURL *)boardURL;

- (NSString *)boardName;
- (NSAttributedString *)localRulesAttrString;
- (NSDate *)lastDate;

- (BOOL)isLoading;
- (NSError *)lastError;
@end


extern NSString *const BSLocalRulesCollectorErrorDomain;
