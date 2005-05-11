//: SGURLEscape.h
/**
  * $Id: SGURLEscape.h,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#ifndef SGURLESCAPE_INCLUDED
#define SGURLESCAPE_INCLUDED



#include <stddef.h>
#include <SGFoundation/SGBase.h>

SG_DECL_BEGIN


SG_EXPORT
char *SGURLEscape(const char *string, size_t length);
SG_EXPORT
char *SGURLUnescape(const char *string, size_t length);


SG_DECL_END

#endif	/* SGURLESCAPE_INCLUDED */
