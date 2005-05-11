//: SGBase64.h
/**
  * $Id: SGBase64.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#ifndef SGBASE64_INCLUDED
#define SGBASE64_INCLUDED

#include <stddef.h>
#include <SGFoundation/SGBase.h>

SG_DECL_BEGIN

SG_EXPORT
int SGBase64Encode(const void *data, size_t size, char **str);
SG_EXPORT
int SGBase64Decode(const char *src, unsigned char *dest);



SG_DECL_END

#endif	/* SGBASE64_INCLUDED */
