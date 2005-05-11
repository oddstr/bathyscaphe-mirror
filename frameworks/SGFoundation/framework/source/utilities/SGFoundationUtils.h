//: SGFoundationUtils.h
/**
  * $Id: SGFoundationUtils.h,v 1.1.1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#ifndef SGFOUNDATIONUTILS_H_INCLUDED
#define SGFOUNDATIONUTILS_H_INCLUDED

#import <SGFoundation/SGBase.h>

#import <SGFoundation/SGUtilLogger.h>
#import <SGFoundation/SGUtilLogHandler.h>
#import <SGFoundation/SGUtilLogFileHandler.h>
#import <SGFoundation/SGUtilLogRecord.h>
#import <SGFoundation/SGUtilLogFormatter.h>
#import <SGFoundation/SGNSR.h>
#import <SGFoundation/SGTemporaryObjects.h>

SG_DECL_BEGIN


/*!
 * @function        SGUtilUngzipIfNeeded
 * @abstract        gzip 解凍
 * @discussion      gzip 圧縮されたデータを解凍し、新しいインスタンスを返す。
 *                  gzip 圧縮されていなければ、渡されたインスタンスをそのまま
 *                  返す。 
 * @param  aData    データ
 * @result          解凍後のデータ
 */
SG_EXPORT
id SGUtilUngzipIfNeeded(NSData *aData);
/*!
 * @function        SGUtilUngzip
 * @abstract        gzip 解凍
 * @discussion      gzip 圧縮されたデータを解凍し、新しいインスタンスを返す。
 *                  返す。 
 * @param  aData    データ
 * @result          解凍後のデータ。gzip 圧縮されていなければ、nil
 */
SG_EXPORT
id SGUtilUngzip(NSData *aData);



SG_DECL_END

#endif /* SGFOUNDATIONUTILS_H_INCLUDED */
