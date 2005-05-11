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
 * @discussion �|�C���^���i�[����z����Ǘ�����\����
 */

#ifndef SGBASECARRAY_H_INCLUDED
#define SGBASECARRAY_H_INCLUDED

#include <CoreServices/CoreServices.h>
#include <SGFoundation/SGBase.h>
SG_DECL_BEGIN


/*!
	@typedef SGBaseCArray
	�|�C���^���i�[����z����Ǘ�����\����
	@field capacity	���ۂɃ��������m�ۂ��Ă���v�f��
	@field count	�v�f��
	@field elements	�v�f�̔z��
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

/* ������ */
SG_EXPORT
SGBaseCArray *SGBaseCArrayInit(SGBaseCArray *self);
/* ��n�� */
SG_EXPORT
SGBaseCArray *SGBaseCArrayFinalize(SGBaseCArray *self);

SG_EXPORT
void **SGBaseCArrayReserve(SGBaseCArray *self, unsigned numElements);

/*!
	@typedef	SGBaseCArrayApplier
	@discussion	SGBaseCArrayApply() �Ŋe�v�f�ɑ΂��Ď��s�����
				�֐��̌^
				
	@field element	�v�f
	@field anIndex	�v�f�̃C���f�b�N�X
	@field userData	SGBaseCArrayApply() �̑�Q����
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
