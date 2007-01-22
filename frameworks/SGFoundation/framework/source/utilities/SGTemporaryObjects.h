/**
  * $Id: SGTemporaryObjects.h,v 1.2 2007/01/22 02:23:29 tsawada2 Exp $
  * 
  * SGTemporaryObjects.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#ifndef SGTEMPOBJECTS_H_INCLUDED
#define SGTEMPOBJECTS_H_INCLUDED

/*!
 * @header     CMXObjectRecycle.h
 * @discussion Recyclable Object Service -- Public API
 */
#import <Foundation/Foundation.h>
#import <SGFoundation/SGFoundationBase.h>
#import <SGFoundation/SGBase.h>


SG_DECL_BEGIN



/*!
 * @abstract   一時可変オブジェクト
 * @discussion 
 * 
 * ***スレッドごとに***割り当てられる可変オブジェクト。
 * 次の呼び出し時に内容はクリアされる。
 * 
 */
SG_EXPORT
NSMutableArray *SGTemporaryArray(void);
SG_EXPORT
NSMutableDictionary *SGTemporaryDictionary(void);
SG_EXPORT
NSMutableAttributedString *SGTemporaryAttributedString(void);
SG_EXPORT
NSMutableString *SGTemporaryString(void);
SG_EXPORT
NSMutableSet *SGTemporarySet(void);
SG_EXPORT
NSMutableData *SGTemporaryData(void);
SG_EXPORT
SGBaseRangeArray *SGTemporaryRangeArray(void);
//SG_EXPORT
//SGBaseBitArrayRef SGTemporaryBitArray(void);




SG_DECL_END

#endif /* SGTEMPOBJECTS_H_INCLUDED */
