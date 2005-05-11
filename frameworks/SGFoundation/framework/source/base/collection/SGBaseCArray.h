/**
  * $Id: SGBaseCArray.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * SGBaseCArray.h
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
/*!
 * @header     SGBaseCArray
 * @discussion ポインタを格納する配列を管理する構造体
 */

#ifndef SGBASECARRAY_H_INCLUDED
#define SGBASECARRAY_H_INCLUDED

#include <CoreServices/CoreServices.h>
#include <SGFoundation/SGBase.h>
SG_DECL_BEGIN


/*!
	@typedef SGBaseCArray
	ポインタを格納する配列を管理する構造体
	@field capacity	実際にメモリを確保している要素数
	@field count	要素数
	@field elements	要素の配列
 */

typedef struct {
	unsigned	capacity;	/* actualy allocated backets count */
	unsigned	count;		/* the number of elements */
	void		**elements;	/* elements in this array */
} SGBaseCArray;

#define SG_BASE_CARRAY_CAPACITY(self)	((self)->capacity)
#define SG_BASE_CARRAY_COUNT(self)		((self)->count)
#define SG_BASE_CARRAY_ELEMENTS(self)	((self)->elements)
#define SG_BASE_CARRAY_AT(self, idx)	((self)->elements[(idx)])

#define SG_BASE_CARRAY_LAST_VALUE(self)	(0 == (self)->count ? NULL : (self)->elements[(self)->count -1])

/* 初期化 */
SG_EXPORT
SGBaseCArray *SGBaseCArrayInit(SGBaseCArray *self);
/* 後始末 */
SG_EXPORT
SGBaseCArray *SGBaseCArrayFinalize(SGBaseCArray *self);

SG_EXPORT
void **SGBaseCArrayReserve(SGBaseCArray *self, unsigned numElements);

/*!
	@typedef	SGBaseCArrayApplier
	@discussion	SGBaseCArrayApply() で各要素に対して実行される
				関数の型
				
	@field element	要素
	@field anIndex	要素のインデックス
	@field userData	SGBaseCArrayApply() の第２引数
*/
typedef void (*SGBaseCArrayApplier)(void *element, unsigned anIndex, void *userData);

SG_EXPORT
void SGBaseCArrayApply(SGBaseCArray *self, SGBaseCArrayApplier applier, void *userData);

SG_EXPORT
void SGBaseCArrayAppendValue(SGBaseCArray *self, void *aValue);
SG_EXPORT
void SGBaseCArrayInsertValueAtIndex(SGBaseCArray *self, void *aValue, unsigned anIndex);

SG_EXPORT
void SGBaseCArrayRemoveValueAtIndex(SGBaseCArray *self, unsigned anIndex);
SG_EXPORT
void SGBaseCArrayRemoveLastValue(SGBaseCArray *self);



SG_DECL_END

#endif /* SGBASECARRAY_H_INCLUDED */
