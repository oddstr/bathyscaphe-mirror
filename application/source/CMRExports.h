/**
  * $Id: CMRExports.h,v 1.2 2005/09/12 08:02:20 tsawada2 Exp $
  * 
  * CMRExports.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */




#ifndef CMREXPORTS_H_INCLUDED
#define CMREXPORTS_H_INCLUDED

#include <stddef.h>

#import <Foundation/Foundation.h>
#import <SGFoundation/SGFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif


@class SGInternalMessenger;


// main browser
extern id					CMRMainBrowser;

// main thread & runLoop...
extern NSThread				*CMRMainThread;
extern NSRunLoop			*CMRMainRunLoop;
extern SGInternalMessenger	*CMRMainMessenger;

extern void CMRApplicationReset(void);

// Alert
extern int CMRRunAlertPanelForDeleteThread(BOOL isFavotites);

/*!
 * @function    CMXInit
 * @discussion  各サービスの初期化
 */
extern void CMXServicesInit(void);

/*!
 * @abstract    ログ出力オブジェクト
 * @discussion  アプリケーション全体で使用するログ出力オブジェクト
 */
extern SGUtilLogger *CMRLogger;

/*!
 * @category    CMXFavoritesDirectoryName
 * @discussion  Version 1 との互換性のためだけの機能
 */
#define CMXFavoritesDirectoryName	NSLocalizedString(@"Favorites", nil)


#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif
#endif /* CMREXPORTS_H_INCLUDED */
