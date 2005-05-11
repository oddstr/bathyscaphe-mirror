/**
  * $Id: SGBaseCArrayWrapper.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * SGBaseCArrayWrapper.h
  *
  * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */

#ifndef SGBASECARRAYWRAPPER_H_INCLUDED
#define SGBASECARRAYWRAPPER_H_INCLUDED

#import <Foundation/Foundation.h>
#import <SGFoundation/SGBase.h>
#import <SGFoundation/SGBaseCArray.h>

SG_DECL_BEGIN



@interface SGBaseCArrayWrapper : NSMutableArray
{
	@private
	SGBaseCArray	m_objects;
}
@end

#define SGBaseCArrayWrapperDefs(me)			\
	((struct { @defs(SGBaseCArrayWrapper) } *) me)




SG_STATIC_INLINE unsigned SGBaseCArrayWrapperCount(SGBaseCArrayWrapper *self)
{
	return SG_BASE_CARRAY_COUNT(&SGBaseCArrayWrapperDefs(self)->m_objects);
}

SG_STATIC_INLINE id SGBaseCArrayWrapperObjectAtIndex(
						SGBaseCArrayWrapper	*self,
						unsigned int		anIndex)
{
	return SG_BASE_CARRAY_ELEMENTS(&SGBaseCArrayWrapperDefs(self)->m_objects)[anIndex];
}



SG_DECL_END

#endif /* SGBASECARRAYWRAPPER_H_INCLUDED */
