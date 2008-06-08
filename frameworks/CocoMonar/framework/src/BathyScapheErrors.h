//
//  BathyScapheErrors.h
//  CMF
//
//  Created by Tsutomu Sawada on 08/03/07.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>


enum {
	// File Read/Write Errors
	BSDocumentReadRequiredAttrNotFoundError = 201, // 書類の内容で必須な部分が欠落
	BSDocumentReadNoDataError = 202, // 書類の内容がまったく無い
	BSDocumentReadTooOldLogFormatError = 203, // ログファイルのフォーマットが古すぎる
	BSDocumentReadCannotCopyLogFileError = 211, // ログファイルを適切な場所にコピーできない

	BSDocumentWriteRequiredAttrNotFoundError = 501, // 書類に書き込むべき必須な内容が欠落
	BSDocumentWriteNoDataError = 502, // 書類に書き込むべき内容がまったく無い

	// Downloader Errors
	BSDATDownloaderThreadNotFoundError = 404, // そんな板orスレッドないです（DAT 落ち？）
	BSThreadTextDownloaderInvalidPartialContentsError = 416, // ダウンロードしたデータが不完全
};

extern NSString *const BSBathyScapheErrorDomain;
