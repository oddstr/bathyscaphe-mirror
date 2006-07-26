//
//  BSIPIDownload.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/07/15.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TemporaryFolder;

@interface BSIPIDownload : NSObject {
	NSURL			*m_URLIdentifier;
	NSURLDownload	*m_download;
	NSString		*m_downloadedFilePath;
	NSString		*m_destination;

	long long  lExLength;  // コンテンツの総容量
	long long  lDlLength;  // ダウンロードした量
	
	id		m_delegate;
}

// 指定イニシャライザ
- (id) initWithURLIdentifier: (NSURL *) anURL
					delegate: (id) aDelegate
				 destination: (NSString *) aPath;

- (NSURL *) URLIdentifier;
- (void) setURLIdentifier: (NSURL *) anURL;

- (NSURLDownload *) URLDownload;

- (NSString *) destination;
- (void) setDestination: (NSString *) aPath;

- (NSString *) downloadedFilePath;
- (void) setDownloadedFilePath: (NSString *) aPath;

- (void) cancel;

- (id) delegate;
- (void) setDelegate: (id) aDelegate;
@end

@interface NSObject(BSIPIDownloadDelegate)
// コンテンツの総容量が推定できたときに送られる
- (void) bsIPIdownload: (BSIPIDownload *) aDownload willDownloadContentOfSize: (double) expectedLength;
// ダウンロードが進む度に進行状況を通知する
- (void) bsIPIdownload: (BSIPIDownload *) aDownload didDownloadContentOfSize: (double) downloadedLength;
// ダウンロード完了
- (void) bsIPIdownloadDidFinish: (BSIPIDownload *) aDownload;

// リダイレクトが発生したときに送られる。YES を返すと続行。NO を返すとダウンロードをキャンセル
- (BOOL) bsIPIdownload: (BSIPIDownload *) aDownload didRedirectToURL: (NSURL *) newURL;

// リダイレクトをブロックしたときに送られる
- (void) bsIPIdownloadDidAbortRedirection: (BSIPIDownload *) aDownload;

// ダウンロード失敗
- (void) bsIPIdownload: (BSIPIDownload *) aDownload didFailWithError: (NSError *) aError;
@end