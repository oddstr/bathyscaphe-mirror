//: misc.h
/**
  * $Id: misc.h,v 1.1 2005/05/11 17:51:03 tsawada2 Exp $
  * 
  * misc.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#ifndef MISC_H_INCLUDED
#define MISC_H_INCLUDED

#import <Foundation/Foundation.h>
#import <SGFoundation/SGFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif



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
#endif /* MISC_H_INCLUDED */
